{
  den,
  inputs,
  config,
  ...
}: let
  inherit (den.lib.policy) route;
in {
  flake-file.inputs = {
    nix-unit.url = "github:nix-community/nix-unit";
    nix-unit.inputs = {
      nixpkgs.follows = "nixpkgs";
      nix-github-actions.follows = "";
    };
  };

  imports = [
    inputs.nix-unit.modules.flake.default
  ];

  den.classes.tests = {};

  den.policies.tests-to-flake-parts = _: [
    (route {
      fromClass = "tests";
      intoClass = "flake-parts";
      collectSubtree = true;
      path = ["nix-unit" "tests"];
      adaptArgs = args: let
        sandbox = config.flake.nixosConfigurations.sandbox.config;
        inherit (sandbox.users.users) artifex;
      in
        args.config.allModuleArgs // {inherit sandbox artifex;};
    })
  ];

  den.schema.flake-parts.includes = [den.policies.tests-to-flake-parts];

  perSystem = _: {
    nix-unit = {
      allowNetwork = true;
      inputs = builtins.removeAttrs inputs ["devenv-root"];
    };
  };
}
