{
  den,
  inputs,
  ...
}:
let
  tests =
    {
      lib,
      aspect-chain,
      class,
      ...
    }:
    den.batteries.forward {
      adaptArgs = { config, ... }: config.allModuleArgs;
      each = lib.singleton class;
      fromAspect = _: lib.last aspect-chain;
      fromClass = _: "tests";
      intoClass = _: "flake-parts";

      intoPath = _: [
        "nix-unit"
        "tests"
      ];
    };
in
{
  flake-file.inputs = {
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    nix-unit.url = "github:nix-community/nix-unit";
  };

  imports = [
    inputs.nix-unit.modules.flake.default
  ];

  den.schema.flake-parts.includes = [ tests ];

  perSystem = _: {
    # nix-unit.inputs = {
    #   # NOTE: a `nixpkgs-lib` follows rule is currently required
    #   inherit (inputs) nixpkgs flake-parts nix-unit;
    # };
    nix-unit = {
      inherit inputs;
    };

    nix-unit.allowNetwork = true;
    # flake = {
    #   # System-agnostic tests can be defined here, and will be picked up by
    #   # `nix flake check`
    # };
  };
}
