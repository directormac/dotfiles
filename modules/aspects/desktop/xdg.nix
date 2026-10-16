# XDG Portal, Mime Types, and User Directories Leaf Aspect
_:
{
  den.aspects.desktop.xdg = {
    nixos =
      _:
      {
        environment.pathsToLink = [
          "/share/xdg-desktop-portal"
          "/share/applications"
        ];
      };

    homeManager =
      {
        config,
        pkgs,
        user,
        ...
      }:
      let
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
      in
      {
        home.file = {
          ".config/wallpapers".source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/wallpapers";
          ".face".source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/.face";
        };

        xdg = {
          enable = true;

          mimeApps = {
            associations.added = {
              "audio/*" = [
                "mpv.desktop"
                "vlc-new-window.desktop"
                "vlc-enqueue.desktop"
              ];

              "inode/directory" = [ "superfile.desktop" ];
              "text/plain" = [ "neovim.desktop" ];

              "video/*" = [
                "mpv.desktop"
                "vlc-new-window.desktop"
                "vlc-enqueue.desktop"
              ];
            };

            defaultApplications = {
              "application/epub+zip" = "com.github.johnfactotum.Foliate.desktop";
              "application/pdf" = "org.gnome.Evince.desktop";
              "application/rar" = "org.gnome.FileRoller.desktop";
              "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
              "application/x-bzip2" = "org.gnome.FileRoller.desktop";
              "application/x-gzip" = "org.gnome.FileRoller.desktop";
              "application/x-rar" = "org.gnome.FileRoller.desktop";
              "application/x-tar" = "org.gnome.FileRoller.desktop";
              "application/x-xz" = "org.gnome.FileRoller.desktop";
              "application/zip" = "org.gnome.FileRoller.desktop";
              "image/*" = [ "feh.desktop" ];
              "inode/directory" = "org.gnome.Nautilus.desktop";
              "text/plain" = "neovim.desktop";
              "video/*" = "vlc.desktop";
              "video/*,.mkv" = "vlc.desktop";
              "x-scheme-handler/discord" = "vesktop.desktop";
              "x-scheme-handler/http" = "zen-beta.desktop";
              "x-scheme-handler/https" = "zen-beta.desktop";
            };

            enable = true;
          };

          portal = {
            config = {
              common = {
                default = [ "gtk" ];
                "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
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

                "org.freedesktop.impl.portal.RemoteDesktop" = [ "hypr_kdeconnect" ];
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

              mango = {
                default = [ "gtk" ];
                "org.freedesktop.impl.portal.Inhibit" = [ "none" ];
                "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
                "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
                "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
              };

              niri = {
                "org.freedesktop.impl.portal.Access" = [ "gtk" ];
                "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
                "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
                "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
                "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
                "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
              };

              sway = {
                default = [
                  "gtk"
                  "wlr"
                ];
              };
            };

            enable = true;

            extraPortals = [
              pkgs.xdg-desktop-portal-gtk
              pkgs.xdg-desktop-portal-gnome
              pkgs.xdg-desktop-portal-hyprland
              pkgs.kdePackages.xdg-desktop-portal-kde
              pkgs.xdg-desktop-portal-wlr
              pkgs.local.hypr-kdeconnect-fix
            ];

            xdgOpenUsePortal = true;
          };

          userDirs = {
            createDirectories = true;
            enable = true;

            extraConfig = {
              XDG_CODE_DIR = "${config.home.homeDirectory}/Code";
              XDG_WORK_DIR = "${config.home.homeDirectory}/Work";
            };
          };
        };
      };
  };

}
