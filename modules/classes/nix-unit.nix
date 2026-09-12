/**
* Test Development Process
*
* This module configures `nix-unit` integration using Den's routing system.
* The `tests-to-flake-parts` policy automatically collects any `tests` defined
* in your aspects (e.g. `modules/aspects/bar.nix`) and routes them into
* the `nix-unit` checks.
*
* To add a new test case:
* 1. Open any of your aspect modules (e.g. `modules/aspects/bar.nix`).
* 2. Define a new test within the `tests` attribute:
*
*    tests.my-new-test = {
*      expr = your_function_to_test;
*      expected = expected_result;
*    };
*
* 3. The test is collected automatically. To execute the tests, run:
*    `nix build .#checks.x86_64-linux.nix-unit` or `nix flake check`
*
* The `adaptArgs` helper also exposes variables like `igloo` and `tux`
* to your tests by default.
*/
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

  imports = [inputs.nix-unit.modules.flake.default];
  den.classes.tests = {};

  # some globals
  perSystem.nix-unit = {
    allowNetwork = true;
    inputs = inputs;
  };

  den.policies.tests-to-flake-parts = _: [
    (route {
      fromClass = "tests";
      intoClass = "flake-parts";
      collectSubtree = true;
      path = [
        "nix-unit"
        "tests"
      ];
      # test helpers
      adaptArgs = args: let
        igloo = config.flake.nixosConfigurations.igloo.config;
        tux = igloo.users.users.tux;
      in
        args.config.allModuleArgs // {inherit igloo tux;};
    })
  ];
  den.schema.flake-parts.includes = [den.policies.tests-to-flake-parts];
}
