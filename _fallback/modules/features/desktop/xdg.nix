{ self, ... }:
{
  flake.homeModules.xdg =
    { config, ... }:
    {

      # https://home-manager-options.extranix.com/?query=xdg&release=master
      xdg = {
        enable = true;
        userDirs = {
          enable = true;
          createDirectories = true;
        };

        mimeApps = {
          enable = true;
          # Find Applications appropriately
          # ls /etc/profiles/per-user/$(id -n -u)/share/applications
          # ls /run/current-system/sw/share/applications/
          defaultApplications = {
            "image/*" = [ "feh.desktop" ];
            "video/*" = "vlc.desktop";
            "video/*,.mkv" = "vlc.desktop";

            "text/plain" = "neovim.desktop";
            "inode/directory" = "org.gnome.Nautilus.desktop";
            "application/epub+zip" = "com.github.johnfactotum.Foliate.desktop";
            "application/pdf" = "org.gnome.Evince.desktop";

            "x-scheme-handler/http" = "zen-beta.desktop";
            "x-scheme-handler/https" = "zen-beta.desktop";
            "x-scheme-handler/discord" = "vesktop.desktop";
          };

          associations.added = {
            "text/plain" = [ "neovim.desktop" ];
          };

        };

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

    # Move to home manager???
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
          # default = [
          #   "gtk"
          #   "gnome"
          # ];
          "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
          "org.freedesktop.impl.portal.Access" = [ "gtk" ];
          "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
        };
        mangowc = {
          default = [
            "gtk"
          ];
          "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          "org.freedesktop.impl.portal.Inhibit" = [ "none" ];
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
