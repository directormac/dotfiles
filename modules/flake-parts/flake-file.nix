{inputs, ...}: {
  imports = [
    (inputs.flake-file.flakeModules.dendritic or {})
    (inputs.den.flakeModules.dendritic or {})
  ];

  flake-file = {
    prune-lock.enable = true;

    nixConfig = {
      abort-on-warn = false;
      accept-flake-config = true;
      allow-import-from-derivation = true;
      auto-optimise-store = true;
      lazy-trees = true;
      submodules = true;
      use-xdg-base-directories = true;

      warn-dirty = false;

      extra-experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];

      trusted-users = ["root" "artifex" "@wheel"];

      extra-substituters = [
        "https://nix-community.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    inputs = {
      den.url = "github:denful/den";
      import-tree.url = "github:vic/import-tree";
      flake-file.url = "github:vic/flake-file";

      flake-parts.url = "github:hercules-ci/flake-parts";

      flake-compat = {
        url = "github:edolstra/flake-compat";
      };
      flake-utils = {
        url = "github:numtide/flake-utils";
        inputs.systems.follows = "systems";
      };

      nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

      home-manager-stable = {
        url = "github:nix-community/home-manager/release-26.05";
        inputs.nixpkgs.follows = "nixpkgs-stable";
      };

      # hm-wrapper-modules = {
      #   # Fork: custom features
      #   url = "github:sini/hm-wrapper-modules";
      #   inputs = {
      #     nixpkgs.follows = "nixpkgs";
      #     nix-wrapper-modules.follows = "nix-wrapper-modules";
      #     home-manager.follows = "home-manager";
      #   };
      # };

      disko = {
        url = "github:nix-community/disko";
      };

      nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

      nixos-hardware.url = "github:nixos/nixos-hardware";

      firefox-addons = {
        url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      gen-schema.url = "github:sini/gen-schema";

      nix-index-database.url = "github:nix-community/nix-index-database";
      nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

      impermanence.url = "github:nix-community/impermanence";

      # nixcord = {
      #   url = "github:kaylorben/nixcord";
      #   inputs = {
      #     nixpkgs.follows = "nixpkgs-unstable";
      #   };
      # };
      #
      # nixhelm.url = "github:nix-community/nixhelm";

      # nixos-anywhere = {
      #   url = "github:numtide/nixos-anywhere";
      #   inputs = {
      #     disko.follows = "disko";
      #     nixos-stable.follows = "nixpkgs";
      #     nixpkgs.follows = "nixpkgs-unstable";
      #     treefmt-nix.follows = "treefmt-nix";
      #   };
      # };

      # stylix = {
      #   url = "github:nix-community/stylix";
      #   inputs.nixpkgs.follows = "nixpkgs-unstable";
      # };

      # wrappers.url = "github:nix-community/nix-wrapper-modules";

      # zen-browser = {
      #   url = "github:0xc000022070/zen-browser-flake";
      #   inputs = {
      #     nixpkgs.follows = "nixpkgs-unstable";
      #     home-manager.follows = "home-manager-unstable";
      #   };
      # };

      # workmux.url = "github:raine/workmux";
    };
  };
}
