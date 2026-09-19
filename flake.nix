# DO-NOT-EDIT. This file was auto-generated using github:denful/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  nixConfig = {
    abort-on-warn = false;
    accept-flake-config = true;
    allow-import-from-derivation = true;
    auto-optimise-store = true;
    extra-experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
    lazy-trees = true;
    submodules = true;
    trusted-users = [
      "root"
      "artifex"
      "@wheel"
    ];
    use-xdg-base-directories = true;
    warn-dirty = false;
  };

  inputs = {
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };
    agenix-rekey = {
      url = "github:sini/agenix-rekey/feat/settings";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-rekey-to-sops = {
      url = "github:sini/agenix-rekey-to-sops";
      inputs = {
        agenix-rekey.follows = "agenix-rekey";
        nixpkgs.follows = "nixpkgs";
      };
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dag.url = "github:denful/dag";
    dankcalendar.url = "github:AvengeMedia/dankcalendar";
    danksearch.url = "github:AvengeMedia/danksearch";
    den.url = "github:denful/den";
    devenv.url = "github:cachix/devenv";
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
    dgop.url = "github:AvengeMedia/dgop";
    disko.url = "github:nix-community/disko";
    dms.url = "github:AvengeMedia/DankMaterialShell";
    dms-plugin-registry.url = "github:AvengeMedia/dms-plugin-registry";
    files.url = "github:sini/files";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat.url = "github:edolstra/flake-compat";
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-root.url = "github:srid/flake-root";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    gen-schema.url = "github:sini/gen-schema";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    impermanence.url = "github:nix-community/impermanence";
    import-tree.url = "github:vic/import-tree";
    lazyvim-nix.url = "github:pfassina/lazyvim-nix";
    make-shell.url = "github:nicknovitski/make-shell";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-unit = {
      url = "github:nix-community/nix-unit";
      inputs = {
        nix-github-actions.follows = "";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nix2container = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
    systems.url = "github:nix-systems/default/future-26.11";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };
}
