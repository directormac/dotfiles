{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  cargoHash = "sha256-pbzCRd6BoImGL2DXInGRiiobk1CnMEmmeH1tetzNLnQ=";
  pname = "leaf";

  src = fetchFromGitHub {
    hash = "sha256-+J8c6aoM2GqZMJe2XUiY4A6T1qqw1s1+kVMhdHKSt8o=";
    owner = "rivolink";
    repo = "leaf";
    rev = version;
  };

  version = "1.29.1";

  meta = {
    description = "Terminal Markdown previewer with a GUI-like experience";
    homepage = "https://github.com/rivolink/leaf";
    license = lib.licenses.mit;
    mainProgram = "leaf";
  };
}
