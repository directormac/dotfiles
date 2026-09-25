{ self, ... }: {
  flake.homeModules.xdg = { pkgs, config, ... }: {

    # home-packages = [
    #   pkgs.xdg-utils
    # ];

    xdg = {
      enable = true;
      userDirs.enable = true;
    };

    home.file = {

      ".face".source = config.lib.file.mkOutOfStoreSymlink "/home/artifex/.dotfiles/config/.face";

      ".config/wallpapers".source =
        config.lib.file.mkOutOfStoreSymlink "/home/artifex/.dotfiles/config/wallpapers";

    };

  };

  flake.nixosModules.xdg = { config, pkgs, ... }: {

    # This is applied to this host with home-manager
    home-manager.users.${config.preferences.user.name} = {
      imports = [
        self.homeModules.xdg
      ];
    };

    security.pam.services = {
      gdm.enableGnomeKeyring = true;
      gdm-password.enableGnomeKeyring = true;
      login.enableGnomeKeyring = true;
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      config = {
        common = {
          default = [ "gtk" ];
        };
        gnome = {
          default = [
            "gnome"
            "gtk"
          ];
        };
        hyprland = {
          default = [
            "hyprland"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
        kde = {
          default = [
            "kde"
            "gtk"
          ];
          "org.freedesktop.portal.FileChooser" = [ "kde" ];
          "org.freedesktop.portal.OpenURI" = [ "kde" ];
        };
        niri = {
          default = [
            "gtk"
            "gnome"
          ];
          "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
          "org.freedesktop.impl.portal.Access" = [ "gtk" ];
          "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
        };
        sway = {
          default = [
            "gtk"
            "wlr"
          ];
        };
      };
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-gnome
        pkgs.xdg-desktop-portal-hyprland
        pkgs.kdePackages.xdg-desktop-portal-kde
        pkgs.xdg-desktop-portal-wlr
      ];
    };

    # Necessary for xdg-portal home-manager module to work with useUserPackages
    environment.pathsToLink = [
      "/share/xdg-desktop-portal"
      "/share/applications"
    ];

  };
}
