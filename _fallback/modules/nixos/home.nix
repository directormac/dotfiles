{ self, inputs, ... }: {
  # Appended to the base
  flake.nixosModules.base = { config, ... }: {

    imports = [
      inputs.home-manager.nixosModules.default # import official home-manager NixOS module
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
    };

    # This is applied to this host with home-manager
    home-manager.users.${config.preferences.user.name} = {
      imports = [
        self.homeModules.homeModule
        self.homeModules.git
        self.homeModules.lazyvim
      ];
    };

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
