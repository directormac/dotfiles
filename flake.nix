{
  description = "
    Dendritic nixos configuration.

    [Dendritic](https://dendrix.denful.dev/index.html)
    [Wiki](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki)

    [flake.parts](https://flake.parts/index.html)

    [wrapper-modules](https://nix-community.github.io/nix-wrapper-modules/md/getting-started.html)
     Uses flake-parts to set up the flake outputs:

    `wrappers`, `wrapperModules` and `packages.*.*`
    ";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    # [Wrapper flake-parts](https://nix-community.github.io/nix-wrapper-modules/md/getting-started.html#flake-parts)
    #
    wrappers.url = "github:nix-community/nix-wrapper-modules";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    # wrapper-manager.url = "git+https://codeberg.org/viperML/wrapper-manager";

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Extras
    noctalia.url = "github:noctalia-dev/noctalia";

    # DankMaterialShell Inputs

    dms.url = "github:AvengeMedia/DankMaterialShell";
    dms-plugin-registry.url = "github:AvengeMedia/dms-plugin-registry";
    dgop.url = "github:AvengeMedia/dgop";
    danksearch.url = "github:AvengeMedia/danksearch";
    dankcalendar.url = "github:AvengeMedia/dankcalendar";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    wshowkeys.url = "github:DreamMaoMao/wshowkeys";

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-multiverse.url = "github:fzakaria/nixpkgs-multiverse";

    workmux.url = "github:raine/workmux";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lazyvim = {
      url = "github:pfassina/lazyvim-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  # outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  # Import all .nix files from current directory except flake.nix recursively
  outputs = inputs: let
    inherit (inputs.nixpkgs) lib;
    inherit (lib.fileset) toList fileFilter;

    isNixModule = file: file.hasExt "nix" && file.name != "flake.nix" && !lib.hasPrefix "_" file.name;

    importTree = path: toList (fileFilter isNixModule path);

    mkFlake = inputs.flake-parts.lib.mkFlake {inherit inputs;};
  in
    mkFlake {imports = importTree ./.;};
}
