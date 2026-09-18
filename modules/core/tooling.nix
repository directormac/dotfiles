/**
* Developer Tooling & Integrations
*
* This module consolidates all external tooling integrations, custom framework classes,
* and command-line runners into a single place.
*
* --- NAMING PACKAGES vs APPS IN DEN ---
* Den automatically generates a package for each host you define (e.g., `packages.x86_64-linux.sandbox`).
* These packages are used by tools like `nh` to build your system configuration.
*
* CRITICAL RULE: Never name a custom script in `perSystem.packages` the same name as one of your hosts!
* If you write `packages.sandbox = ...`, you will accidentally overwrite the system builder package that
* Den relies on. This creates a circular dependency, resulting in an "infinite recursion" error.
*
* HOW TO CREATE CLEAN CLI COMMANDS (e.g., `nix run .#sandbox`):
* 1. Name the actual package something unique (like `sandbox-vm` or `run-sandbox`).
* 2. Expose it via the `apps` output (e.g., `apps.sandbox = ...`).
* `nix run` prefers apps over packages! By mapping `apps.sandbox` to `packages.sandbox-vm`,
* you get the clean command `nix run .#sandbox` without colliding with Den's host packages!
*/
{
  den,
  inputs,
  config,
  runner,
  ...
}: let
  inherit (den.lib.policy) route;
in {
  flake-file = {
    nixConfig = {
      extra-substituters = [
        "https://devenv.cachix.org"
      ];
      extra-trusted-public-keys = [
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
    };

    inputs = {
      devenv-root = {
        url = "file+file:///dev/null";
        flake = false;
      };
      devenv.url = "github:cachix/devenv";
      nix2container = {
        url = "github:nlewo/nix2container";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";

      files.url = "github:sini/files";

      nix-unit.url = "github:nix-community/nix-unit";
      nix-unit.inputs = {
        nixpkgs.follows = "nixpkgs";
        nix-github-actions.follows = "";
      };

      treefmt-nix.url = "github:numtide/treefmt-nix";
      treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  imports = [
    inputs.devenv.flakeModule
    inputs.files.flakeModule
    inputs.nix-unit.modules.flake.default
    inputs.treefmt-nix.flakeModule
  ];

  # --- Den Classes Declaration ---
  den.classes.devenv = {};
  den.classes.files = {};
  den.classes.tests = {};
  den.classes.treefmt = {};

  # --- Policies (Routing to flake-parts) ---
  den.policies.devenv-to-flake-parts = _: [
    (route {
      fromClass = "devenv";
      intoClass = "flake-parts";
      path = ["devenv" "shells" "default"];
      adaptArgs = {config, ...}: config.allModuleArgs;
    })
  ];

  den.policies.files-to-flake-parts = _: [
    (route {
      fromClass = "files";
      intoClass = "flake-parts";
      path = ["files"];
      adaptArgs = {config, ...}: config.allModuleArgs;
    })
  ];

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

  den.policies.treefmt-to-flake-parts = _: [
    (route {
      fromClass = "treefmt";
      intoClass = "flake-parts";
      path = ["treefmt"];
      adaptArgs = {config, ...}: config.allModuleArgs;
    })
  ];

  den.schema.flake-parts.includes = [
    den.policies.devenv-to-flake-parts
    den.policies.files-to-flake-parts
    den.policies.tests-to-flake-parts
    den.policies.treefmt-to-flake-parts
  ];

  # --- Tooling Configurations ---
  # Add the VM gui to the sandbox host
  den.aspects.sandbox.includes = [
    runner.vm.gui
  ];

  perSystem = {
    pkgs,
    config,
    ...
  }: {
    nix-unit = {
      allowNetwork = true;
      inputs = builtins.removeAttrs inputs ["devenv-root"];
    };

    packages =
      (den.lib.nh.denPackages {fromFlake = true;} pkgs)
      // {
        sandbox-vm = pkgs.writeShellApplication {
          name = "sandbox-vm";
          text = ''
            ${inputs.self.nixosConfigurations.sandbox.config.system.build.vm}/bin/run-sandbox-vm "$@"
          '';
        };
      };

    # By mapping apps.sandbox -> packages.sandbox-vm, we get the clean `nix run .#sandbox`
    # CLI command without colliding with the framework's `packages.sandbox` host builder!
    apps.sandbox = {
      type = "app";
      program = "${config.packages.sandbox-vm}/bin/sandbox-vm";
    };
  };
}
