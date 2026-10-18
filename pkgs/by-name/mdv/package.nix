{
  lib,
  fetchFromGitHub,
  makeBinaryWrapper,
  mermaid-cli,
  rustPlatform,
  writeShellScriptBin,
}:

let
  mermaidCliCompat = writeShellScriptBin "mmdc" ''
    args=()
    while [[ $# -gt 0 ]]; do
      case "$1" in
        -w|--width|-H|--height)
          args+=(--size "$2")
          shift 2
          ;;
        -w=*|--width=*|-H=*|--height=*)
          args+=(--size "''${1#*=}")
          shift
          ;;
        *)
          args+=("$1")
          shift
          ;;
      esac
    done
    exec "${lib.getExe mermaid-cli}" "''${args[@]}"
  '';
in
rustPlatform.buildRustPackage {
  cargoHash = "sha256-BbVOc87Vrth5W9tU1N0/hbefUwM7C4EQyeDqQBEWfsw=";
  nativeBuildInputs = [ makeBinaryWrapper ];

  passthru = {
    mermaid-cli = mermaidCliCompat;
  };

  pname = "mdv";

  postInstall = ''
    wrapProgram $out/bin/mdv \
      --prefix PATH : ${lib.makeBinPath [ mermaidCliCompat ]}
  '';

  src = fetchFromGitHub {
    hash = "sha256-5pKZ9Y1XKzB4NTqwRZ4WIXJ4sgdzclLFWoCfWZcpDkI=";
    owner = "posaune0423";
    repo = "mdv";
    rev = "739511ec80d6b2bc552febd47ffce47e1a9d3368";
  };

  version = "0.1.1-unstable-2026-03-29";

  meta = {
    description = "High-fidelity Markdown viewer for Ghostty and Kitty built in Rust";
    homepage = "https://github.com/posaune0423/mdv";
    license = lib.licenses.mit;
    mainProgram = "mdv";
  };
}
