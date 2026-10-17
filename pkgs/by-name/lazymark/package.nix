{
  fetchurl,
  stdenv,
}:

let
  artifact = artifacts.${system} or (throw "Unsupported system for lazymark: ${system}");
  artifacts = {
    aarch64-darwin = {
      hash = "sha256-m0+XEta2kgY9qqcGOi09usff2SI3THTq4n6VP43foHQ=";
      target = "darwin_arm64";
    };

    aarch64-linux = {
      hash = "sha256-kdtGSdEPUvHc5GU9k5mINgskE0YFL+p4QB7BBIF63B0=";
      target = "linux_arm64";
    };

    x86_64-darwin = {
      hash = "sha256-wOx3E4Q8TjjOEPcY9p6Kp1aiazEF1qzgkpHEzWObUDM=";
      target = "darwin_amd64";
    };

    x86_64-linux = {
      hash = "sha256-tvRPPftWhIj2mxHFLUf6+/0+T8F4glykrdtlsM3PENU=";
      target = "linux_amd64";
    };
  };
  system = stdenv.hostPlatform.system;
in
stdenv.mkDerivation rec {
  installPhase = ''
    install -Dm755 lazymark $out/bin/lazymark
  '';

  pname = "lazymark";
  sourceRoot = ".";

  src = fetchurl {
    inherit (artifact) hash;
    url = "https://github.com/MathiasDrizzy/lazymark/releases/download/v${version}/lazymark_${version}_${artifact.target}.tar.gz";
  };

  version = "1.2.2";

  meta = {
    description = "Lazy markdown notes, tasks and a Kanban board in your terminal";
    homepage = "https://github.com/MathiasDrizzy/lazymark";
    mainProgram = "lazymark";
  };
}
