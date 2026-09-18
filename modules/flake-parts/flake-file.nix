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

      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

      nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

      nix-index-database.url = "github:nix-community/nix-index-database";
      nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

      flake-parts.url = "github:hercules-ci/flake-parts";
      flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

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
