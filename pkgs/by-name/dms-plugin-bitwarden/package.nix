{
  lib,
  fetchFromGitHub,
  rustPlatform,
  stdenvNoCC,
}:
let
  agentHelper = rustPlatform.buildRustPackage {
    inherit version src;
    cargoHash = "sha256-D99/+aH/u07zUv7abWf+zYtChdbqwT9pqb1bG1MaM3Y=";
    doCheck = false;
    pname = "qs-bitwarden-ssh-agent";
    sourceRoot = "${src.name}/agent";
  };
  src = fetchFromGitHub {
    hash = "sha256-KuUkDDoTDwMyJixhRN39svFvwuFkZ88nKQXMiP7h1YU=";
    owner = "coldi1337";
    repo = "dms-bitwarden-cli";
    rev = "8b74d727e7c0d3ecf6535278bbff058a8b332cc3";
  };
  unlockKeyHelper = rustPlatform.buildRustPackage {
    inherit version src;
    cargoHash = "sha256-k8HmVZT2Cwh1l2ElokM1/Qug+7sxyDs6oqh8AS8zgS4=";
    doCheck = false;
    pname = "qs-bitwarden-unlock-key";
    sourceRoot = "${src.name}/unlock-key";
  };
  vaultHelper = rustPlatform.buildRustPackage {
    inherit version src;
    cargoHash = "sha256-wfiuE07Avf2pnoVfK4A60eAQ+EyzFvnVOj+vwR6H+JM=";
    doCheck = false;
    pname = "qs-bitwarden-vault";
    sourceRoot = "${src.name}/vault";
  };
  version = "dms/1.11.6-dms.4";
in
stdenvNoCC.mkDerivation {
  inherit version src;
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r ./* $out/

    mkdir -p $out/vault/target/debug
    cp ${vaultHelper}/bin/qs-bitwarden-vault $out/vault/target/debug/
    chmod +x $out/vault/target/debug/qs-bitwarden-vault
    bash $out/scripts/helper-source-hash.sh $out/vault > $out/vault/target/debug/qs-bitwarden-vault.source-sha256

    mkdir -p $out/unlock-key/target/debug
    cp ${unlockKeyHelper}/bin/qs-bitwarden-unlock-key $out/unlock-key/target/debug/
    chmod +x $out/unlock-key/target/debug/qs-bitwarden-unlock-key
    bash $out/scripts/helper-source-hash.sh $out/unlock-key > $out/unlock-key/target/debug/qs-bitwarden-unlock-key.source-sha256

    mkdir -p $out/agent/target/debug
    cp ${agentHelper}/bin/qs-bitwarden-ssh-agent $out/agent/target/debug/
    chmod +x $out/agent/target/debug/qs-bitwarden-ssh-agent
    bash $out/scripts/helper-source-hash.sh $out/agent > $out/agent/target/debug/qs-bitwarden-ssh-agent.source-sha256

    runHook postInstall
  '';

  pname = "dms-plugin-bitwarden";

  meta = {
    description = "Bitwarden Dankbar plugin for Dux Shell with precompiled Rust helpers";
    homepage = "https://github.com/coldi1337/dms-bitwarden-cli";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
