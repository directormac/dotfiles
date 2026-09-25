{ self, ... }: {

  flake.homeModules.hyprland = { config, ... }: {
    home.file = {
      ".config/hypr".source = config.lib.file.mkOutOfStoreSymlink "/home/artifex/.dotfiles/config/hypr";
    };

  };

  flake.nixosModules.hyprland = { pkgs, config, ... }: {

    # This is applied to this host with home-manager
    home-manager.users.${config.preferences.user.name} = {
      imports = [
        self.homeModules.hyprland
      ];
    };

    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    environment.systemPackages = with pkgs; [
      # Used for default config SUPER+R
      hyprlauncher
      hyprpolkitagent

      qt5.qtwayland
      qt6.qtwayland
    ];

  };
}
