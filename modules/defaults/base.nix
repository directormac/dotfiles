{
  inputs,
  lib,
  ...
}: {
  flake-file.inputs = {
    inputs.flake-file.url = lib.mkDefault "github:vic/flake-file";

    inputs.den.url = lib.mkDefault "github:denful/den";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-26.05";

    # [Wrapper flake-parts](https://nix-community.github.io/nix-wrapper-modules/md/getting-started.html#flake-parts)
    wrappers.url = "github:nix-community/nix-wrapper-modules";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    workmux.url = "github:raine/workmux";

    lazyvim = {
      url = "github:pfassina/lazyvim-nix";
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
  };

  den = {
    default = {
      nixos.system.stateVersion = "26.05";
      homeManager.home.stateVersion = "26.05";
    };
    schema = {
      host.includes = [
        ({host, ...}: {
          nixos._module.args.pkgs = inputs.nixpkgs.legacyPackages.${host.system};
        })
      ];

      user = {
        classes = lib.mkDefault ["homeManager"];
        includes = [
          ({host, ...}: {
            homeManager._module.args.pkgs = inputs.nixpkgs.legacyPackages.${host.system};
          })
        ];
      };
    };
  };
}
