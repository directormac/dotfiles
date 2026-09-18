/**
* Flake Inputs and Dendritic Template
*
* This repo is generated from the dendritic template.
* This module manages the core flake inputs and imports the dendritic flakeModules.
*
* Use Case: When you need to add a new input to your flake, you define it here.
* Run `nix run .#write-flake` afterward, which will read this file and
* update the auto-generated `flake.nix` lockfiles.
*/
{inputs, ...}: {
  imports = [
    (inputs.flake-file.flakeModules.dendritic or {})
    (inputs.den.flakeModules.dendritic or {})
  ];

  flake-file.inputs = {
    den.url = "github:denful/den";
    import-tree.url = "github:vic/import-tree";
    flake-file.url = "github:vic/flake-file";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";

    # wrappers.url = "github:nix-community/nix-wrapper-modules";
    # zen-browser = {
    #   url = "github:0xc000022070/zen-browser-flake";
    #   inputs = {
    #     nixpkgs.follows = "nixpkgs";
    #     home-manager.follows = "home-manager";
    #   };
    # };

    # workmux.url = "github:raine/workmux";
  };
}
