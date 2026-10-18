{
  lib,
  fetchCrate,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  cargoHash = "sha256-rAqUXEenI3uME/bX/I1MYqsco3cOzP0v/tR5mk9RaoU=";
  pname = "lessi";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-y0clIs9j17+6YkUJgXAiKjGTT2OXuUMuKhi1sJPJH2Y=";
  };

  version = "0.3.0";

  meta = {
    description = "A terminal pager with integrated sixel and kitty graphics protocol support";
    homepage = "https://github.com/roblillack/lessi";
    license = lib.licenses.mit;
    mainProgram = "lessi";
  };
}
