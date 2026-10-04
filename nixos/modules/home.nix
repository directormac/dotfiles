{ self, inputs, ... }: {
  # Appended to the base
  flake.nixosModules.base = { config, ... }: {

    imports = [
      inputs.home-manager.nixosModules.default # import official home-manager NixOS module
    ];

    documentation = {
      enable = true;
      doc.enable = true;
      dev.enable = false;
      man.enable = true;
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      sharedModules = [
        self.homeModules.preferences
        (
          { osConfig, lib, ... }:
          {
            preferences.user.name = lib.mkDefault osConfig.preferences.user.name;
            preferences.user.email = lib.mkDefault osConfig.preferences.user.email;
            preferences.defaultSession = lib.mkDefault osConfig.preferences.defaultSession;
            preferences.keymap = lib.mkDefault osConfig.preferences.keymap;
            preferences.persistence = lib.mkDefault osConfig.preferences.persistence;
          }
        )
      ];
    };

    # This is applied to this host with home-manager
    home-manager.users.${config.preferences.user.name} = {
      imports = [
        self.homeModules.homeModule
      ];
    };

  };

  # This is your home.nix, your module where you configure home-manager
  # It's imported both in standalone configuration above, and in your nixos configuration
  flake.homeModules.homeModule = { pkgs, ... }: {
    home = {
      sessionPath = [ "$HOME/.local/bin" ];
      packages = [ pkgs.hello ];
      stateVersion = "26.11";
    };
  };

}
