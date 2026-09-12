# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);

  inputs = {
    # den.url = "github:denful/den";
    # flake-parts = {
    #   inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    #   url = "github:hercules-ci/flake-parts";
    # };
    # import-tree.url = "github:vic/import-tree";
    # nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
    nixpkgs-lib.follows = "nixpkgs";

    den.url = "github:denful/den";
    flake-file.url = "github:vic/flake-file";
    import-tree.url = "github:vic/import-tree";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };

    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";

    files.url = "github:mightyiam/files";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    nix-unit.url = "github:nix-community/nix-unit";
    nix-unit.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-parts.follows = "flake-parts";
      # nix-github-actions.follows = "";
    };
  };
}
