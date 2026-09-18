/**
* Developer Tooling & Integrations
*
* This module consolidates all external tooling integrations, custom framework classes,
* and command-line runners into a single place.
*
* It provides:
* 1. `treefmt`: The standard formatter (run via `nix fmt`).
* 2. `devshell`: Environments for development (run via `nix develop`).
* 3. `tests`: Unit testing framework via `nix-unit` (run via `nix build .#checks.x86_64-linux.nix-unit`).
* 4. `files`: File generation tooling.
* 5. `nh` (Nix Helper): Automatically generates fast, user-friendly wrapper apps to build your hosts.
* 6. Custom Runner Scripts: Scripts like `run-igloo` to spin up a VM of your host.
*
* HOW TO ADD A NEW SCRIPT:
* Just add a new attribute to `perSystem.packages` below. For example:
* run-vmzero = pkgs.writeShellApplication {
*   name = "run-vmzero";
*   text = ''${inputs.self.nixosConfigurations.vmzero.config.system.build.vm}/bin/run-vmzero-vm "$@"'';
* };
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
  flake-file.inputs = {
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    files.url = "github:sini/files";

    nix-unit.url = "github:nix-community/nix-unit";
    nix-unit.inputs = {
      nixpkgs.follows = "nixpkgs";
      nix-github-actions.follows = "";
    };

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [
    inputs.devshell.flakeModule
    inputs.files.flakeModule
    inputs.nix-unit.modules.flake.default
    inputs.treefmt-nix.flakeModule
  ];

  # --- Den Classes Declaration ---
  den.classes.devshell = {};
  den.classes.files = {};
  den.classes.tests = {};
  den.classes.treefmt = {};

  # --- Policies (Routing to flake-parts) ---
  den.policies.devshell-to-flake-parts = _: [
    (route {
      fromClass = "devshell";
      intoClass = "flake-parts";
      path = ["devshells" "default"];
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
        igloo = config.flake.nixosConfigurations.igloo.config;
        tux = igloo.users.users.tux;
      in
        args.config.allModuleArgs // {inherit igloo tux;};
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
    den.policies.devshell-to-flake-parts
    den.policies.files-to-flake-parts
    den.policies.tests-to-flake-parts
    den.policies.treefmt-to-flake-parts
  ];

  # --- Tooling Configurations ---
  # Add the VM gui to the igloo host
  den.aspects.igloo.includes = [
    runner.vm.gui
  ];

  perSystem = {pkgs, ...}: {
    nix-unit = {
      allowNetwork = true;
      inputs = inputs;
    };

    packages =
      (den.lib.nh.denPackages {fromFlake = true;} pkgs)
      // {
        run-igloo = pkgs.writeShellApplication {
          name = "run-igloo";
          text = ''
            ${inputs.self.nixosConfigurations.igloo.config.system.build.vm}/bin/run-igloo-vm "$@"
          '';
        };
      };
  };
}
