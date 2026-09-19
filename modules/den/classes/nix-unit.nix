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
      # Test helpers.
      adaptArgs = args: let
        sandbox = config.flake.nixosConfigurations.fulgur.config;
        inherit (sandbox.users.users) mac;
      in
        args.config.allModuleArgs // {inherit sandbox mac;};

      # adaptArgs = args:
      #   args.config.allModuleArgs;
    })
  ];

  den.schema.flake-parts.includes = [den.policies.tests-to-flake-parts];

  perSystem.nix-unit = {
    allowNetwork = true;
    inherit inputs;
  };

  # perSystem = _: {
  #   nix-unit = {
  #     allowNetwork = true;
  #     inputs = removeAttrs inputs ["devenv-root"];
  #   };
  # };
}
