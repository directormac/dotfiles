{
  config,
  den,
  inputs,
  ...
}:
let
  inherit (den.lib.policy) route;
in
{
  flake-file.inputs = {
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    nix-unit.url = "github:nix-community/nix-unit";
  };

  imports = [
    (inputs.nix-unit.modules.flake.default or { })
  ];

  den.classes.tests = {
    description = "Forwarder for aspect unit tests into flake-parts nix-unit";
  };

  den.policies.tests-to-flake-parts = _: [
    (route {
      adaptArgs = { config, ... }: config.allModuleArgs;
      collectSubtree = true;
      fromClass = "tests";
      intoClass = "flake-parts";

      path = [
        "nix-unit"
        "tests"
      ];
    })
  ];

  den.schema.flake-parts.includes = [ config.den.policies.tests-to-flake-parts ];

  perSystem =
    { lib, ... }:
    lib.optionalAttrs (inputs ? nix-unit) {
      nix-unit = {
        inputs = lib.filterAttrs (
          _: input: input ? outPath && builtins.readFileType input.outPath == "directory"
        ) inputs;
      };

      nix-unit.allowNetwork = true;
    };
}
