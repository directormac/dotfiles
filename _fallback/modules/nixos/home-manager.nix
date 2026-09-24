{ self, inputs, ... }: {

  # This is your module that imports and configures home-manager
  flake.nixosModules.homeManagerModule = { pkgs, ... }: {
    imports = [
      inputs.home-manager.nixosModules.default # import official home-manager NixOS module
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };

  # This is your standalone home-manager configuration, meant to be used on non-nixos machines
  # with the home-manager command
  flake.homeConfigurations.home = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
    modules = [
      self.homeModules.homeModule
      {
        home.username = "artifex";
        home.homeDirectory = "/home/artifex";
      }
    ];
  };

  # This is your home.nix, your module where you configure home-manager
  # It's imported both in standalone configuration above, and in your nixos configuration
  flake.homeModules.homeModule = { pkgs, ... }: {
    programs.bash.enable = true;
    programs.bash.shellAliases.ll = "ls -l";

    home.packages = [ pkgs.hello ];
    home.stateVersion = "26.11";
  };

}

