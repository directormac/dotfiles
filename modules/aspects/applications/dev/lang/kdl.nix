# KDL Document Language Aspect
_:
let
  mkKdlLsp =
    pkgs:
    pkgs.rustPlatform.buildRustPackage {
      buildAndTestSubdir = "tools/kdl-lsp";
      cargoHash = "sha256-lAmfaH3SpX0Al2VuT+V/0K5+KpwV0uIKZV0idoUy08w=";
      pname = "kdl-lsp";

      src = pkgs.fetchFromGitHub {
        hash = "sha256-Fx6yjh/JmCxrQWWkqJRQwCoeWRQ6OZPm3zHpPLaUYMQ=";
        owner = "kdl-org";
        repo = "kdl-rs";
        rev = "7de9eb2f4879f3f86157bf2345c93ed52db88e7a";
      };

      version = "0.1.0";
    };
in
{
  den.aspects.applications.dev.lang.kdl = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.kdlfmt
          (mkKdlLsp pkgs)
        ];
      };
  };

  flake.wrappers.neovim =
    { pkgs, ... }:
    {
      config.specs.kdl = {
        data = null;

        runtimePkgs = [
          pkgs.kdlfmt
          (mkKdlLsp pkgs)
        ];
      };
    };
}
