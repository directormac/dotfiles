{
  lib,
  autoPatchelfHook,
  fetchurl,
  makeWrapper,
  stdenv,
  tmux,
}:

let
  key = platformKeys.${system} or (throw "collie: unsupported system ${system}");
  payload = platforms.${key};
  platformKeys = {
    "aarch64-darwin" = "macos-arm64";
    "aarch64-linux" = "linux-arm64";
    "x86_64-darwin" = "macos-x64";
    "x86_64-linux" = "linux-x64";
  };
  platforms = {
    "linux-arm64" = {
      sha256 = "ec3b5fe089e0c0ea62dd542a42259c81dbd4aba05d32fde8f0a2d442df203f35";
      url = "https://github.com/AltanS/collie/releases/download/v${version}/collie-${version}-linux-arm64.tar.gz";
    };

    "linux-x64" = {
      sha256 = "sha256-ZU6T3ZHwh6rQAeUALpORopXhZijYWS02rErz06FM4PA=";
      url = "https://github.com/AltanS/collie/releases/download/v${version}/collie-${version}-linux-x64.tar.gz";
    };

    "macos-arm64" = {
      sha256 = "c1b8f64e249fe97f27e6e7699aa2fc2b272435168c7ba26ea6e3a2b6c587a243";
      url = "https://github.com/AltanS/collie/releases/download/v${version}/collie-${version}-macos-arm64.tar.gz";
    };

    "macos-x64" = {
      sha256 = "e3c386eb13469b1f9c5a684fa01279efc7df68398db25c5aa7475700ac536820";
      url = "https://github.com/AltanS/collie/releases/download/v${version}/collie-${version}-macos-x64.tar.gz";
    };
  };
  system = stdenv.hostPlatform.system;
  version = "1.24.0";
in
stdenv.mkDerivation {
  inherit version;
  doInstallCheck = true;
  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;

  installCheckPhase = ''
    runHook preInstallCheck
    echo "collie version: $("$out/bin/collie" --version)"
    runHook postInstallCheck
  '';

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

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  pname = "collie";

  src = fetchurl {
    inherit (payload) url sha256;
  };

  meta = {
    description = "Self-hosted mobile client PWA for terminal AI coding agents (Herdr, tmux, zellij)";
    homepage = "https://github.com/AltanS/collie";
    license = lib.licenses.mit;
    mainProgram = "collie";
    platforms = builtins.attrNames platformKeys;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
