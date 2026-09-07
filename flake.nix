{
  description = "
    Dendritic nixos configuration.
    [Wiki](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki)
    [flake.parts](https://flake.parts/index.html)
    [wrapper-modules](https://nix-community.github.io/nix-wrapper-modules/md/getting-started.html)
    ";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    # [Wrapper flake-parts](https://nix-community.github.io/nix-wrapper-modules/md/getting-started.html#flake-parts)
    wrappers.url = "github:nix-community/nix-wrapper-modules";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
