{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  cargoHash = "sha256-FP5zPyt961m5xCuWdXoYLYcj8vP01X6IgFlDqnhHpOk=";
  pname = "lazyrsync";

  src = fetchFromGitHub {
    hash = "sha256-v4/UvglfXHmTmotK3wb0czKHyTJbWiDb6uxMuBmkwIo=";
    owner = "westpoint-io";
    repo = "lazyrsync";
    rev = "v${version}";
  };

  version = "0.4.0";

  meta = {
    description = "Terminal UI for rsync with reusable profiles and live progress";
    homepage = "https://github.com/westpoint-io/lazyrsync";
    license = lib.licenses.mit;
    mainProgram = "lazyrsync";
  };
}
