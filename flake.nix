{

  description = "Mac's nix configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos.url = "nixpkgs/nixos-unstable";

    home_manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    nixpkgs-wayland.inputs.nixpkgs.follows = "nixpkgs";

    wezterm = {
      url = "github:wez/wezterm/main?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {

    nixosConfigurations = {

      nixos-test = let
        username = "artifex";
        specialArgs = { inherit username inputs; };
      in nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_640-linux";

        modules = [
          ./hosts/nixos-test
          #./users/${username}/nixos.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = inputs // specialArgs;
            home-manager.users.${username} =
              import ./users/${username}/home.nix;
          }
        ];
      };

      hypr-playground = let
        username = "artifex";
        specialArgs = { inherit username inputs; };
      in nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_640-linux";

        modules = [
          ./hosts/hypr-playground

          #./users/${username}/nixos.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = inputs // specialArgs;
            home-manager.users.${username} =
              import ./users/${username}/home.nix;

          }
        ];
      };

      sway-playground = let
        username = "artifex";
      specialArgs = { inherit username inputs;};
      in nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_640-linux";

        modules = [
          ./hosts/sway-playground

          #./users/${username}/nixos.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = inputs // specialArgs;
            home-manager.users.${username} =
              import ./users/${username}/home.nix;

          }
        ];

      };
    };

    #  nixosConfigurations.super= nixpkgs.lib.nixosSystem {
    #    system = "x86_64-linux";
    #    specialArgs = { inherit inputs; };
    #    modules = [
    # ./configuration.nix
    #
    # home-manager.nixosModules.home-manager
    # {
    #  home-manager.useGlobalPkgs = true;
    #  home-manager.useUserPackages = true;
    #  home-manager.backupFileExtension = "backup";
    #
    #  home-manager.users.artifex = import ./home.nix;
    # }
    #    ];
    #  };
    #  };
  };
}
