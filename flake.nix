{
  description = "
    Dedritic nixos configuration.
    [Reference](https://www.vimjoyer.com/nix/dendritic-home-manager)
    ";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
    noctalia.url = "github:noctalia-dev/noctalia";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    lazyvim.url = "github:pfassina/lazyvim-nix";
  };
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
