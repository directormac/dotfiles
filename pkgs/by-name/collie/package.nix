{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  tmux,
}:

let
  version = "1.23.3";

  platformKeys = {
    "x86_64-linux" = "linux-x64";
    "aarch64-linux" = "linux-arm64";
    "aarch64-darwin" = "macos-arm64";
    "x86_64-darwin" = "macos-x64";
  };

  platforms = {
    "linux-x64" = {
      url = "https://github.com/AltanS/collie/releases/download/v${version}/collie-${version}-linux-x64.tar.gz";
      sha256 = "364ac59adefa077a09e4799c41c20fee7626e2f1002d9eeb1e40bed4d318cabc";
    };
    "linux-arm64" = {
      url = "https://github.com/AltanS/collie/releases/download/v${version}/collie-${version}-linux-arm64.tar.gz";
      sha256 = "ec3b5fe089e0c0ea62dd542a42259c81dbd4aba05d32fde8f0a2d442df203f35";
    };
    "macos-arm64" = {
      url = "https://github.com/AltanS/collie/releases/download/v${version}/collie-${version}-macos-arm64.tar.gz";
      sha256 = "c1b8f64e249fe97f27e6e7699aa2fc2b272435168c7ba26ea6e3a2b6c587a243";
    };
    "macos-x64" = {
      url = "https://github.com/AltanS/collie/releases/download/v${version}/collie-${version}-macos-x64.tar.gz";
      sha256 = "e3c386eb13469b1f9c5a684fa01279efc7df68398db25c5aa7475700ac536820";
    };
  };

  system = stdenv.hostPlatform.system;
  key = platformKeys.${system} or (throw "collie: unsupported system ${system}");
  payload = platforms.${key};
in
stdenv.mkDerivation {
  pname = "collie";
  inherit version;

  src = fetchurl {
    inherit (payload) url sha256;
  };

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/collie" "$out/bin"
    cp -R ./. "$out/lib/collie/"
    chmod +x "$out/lib/collie/bin/collie"
    [ -d "$out/lib/collie/scripts" ] && chmod +x "$out/lib/collie/scripts"/*.sh
    ln -s "$out/lib/collie/bin/collie" "$out/bin/.collie-unwrapped"

    makeWrapper "$out/bin/.collie-unwrapped" "$out/bin/collie" \
      --set-default COLLIE_TMUX_BIN "${tmux}/bin/tmux" \
      --prefix PATH : "${lib.makeBinPath [ tmux ]}"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    echo "collie version: $("$out/bin/collie" --version)"
    runHook postInstallCheck
  '';

  meta = {
    description = "Self-hosted mobile client PWA for terminal AI coding agents (Herdr, tmux, zellij)";
    homepage = "https://github.com/AltanS/collie";
    license = lib.licenses.mit;
    mainProgram = "collie";
    platforms = builtins.attrNames platformKeys;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
