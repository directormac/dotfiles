# This repo was generated with github:vic/flake-file#dendritic template.
# Run `nix run .#write-flake` after changing any input.
#
# Inputs can be placed in any module, the best practice is to have them
# as close as possible to their actual usage.
# See: https://denful.dev/Dendritic.html#minimal-and-focused-flakenix
#
# For our template, we enable home-manager and nix-darwin by default, but
# you are free to remove them if not being used by you.
{
  flake-file.inputs = {
    den.url = "github:denful/den";
    import-tree.url = "github:vic/import-tree";
    flake-file.url = "github:vic/flake-file";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";

    files.url = "github:mightyiam/files";
    files.flake = false;

    devshell.url = "github:numtide/devshell";

    devshell.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    nix-unit.url = "github:nix-community/nix-unit";
    nix-unit.inputs = {
      nixpkgs.follows = "nixpkgs";
      nix-github-actions.follows = "";
    };

    ## these stable inputs are for wsl
    #nixpkgs-stable.url = "github:nixos/nixpkgs/release-25.05";
    #home-manager-stable.url = "github:nix-community/home-manager/release-25.05";
    #home-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable";

    #nixos-wsl = {
    #  url = "github:nix-community/nixos-wsl";
    #  inputs.nixpkgs.follows = "nixpkgs-stable";
    #  inputs.flake-compat.follows = "";
    #};
  };
}
