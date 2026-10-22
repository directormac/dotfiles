# XDG Portal, Mime Types, and User Directories Leaf Aspect
{
  den.aspects.desktop.xdg = {
    nixos = {
      environment.pathsToLink = [
        "/share/xdg-desktop-portal"
        "/share/applications"
      ];
    };

    homeManager =
      {
        config,
        pkgs,
        ...
      }:
      {
        home.file = {
          ".config/wallpapers".source = config.lib.dots.link "wallpapers";
          ".face".source = config.lib.dots.link ".face";
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
                "mpv-enqueue.desktop"
                "mpv-new-window.desktop"
                "vlc-new-window.desktop"
                "vlc-enqueue.desktop"
              ];
            };

            defaultApplications = {
              "application/epub+zip" = "com.github.johnfactotum.Foliate.desktop";
              "application/ogg" = "mpv.desktop";
              "application/pdf" = "org.gnome.Evince.desktop";
              "application/rar" = "org.gnome.FileRoller.desktop";
              "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
              "application/x-bzip2" = "org.gnome.FileRoller.desktop";
              "application/x-gzip" = "org.gnome.FileRoller.desktop";
              "application/x-matroska" = "mpv.desktop";
              "application/x-ogg" = "mpv.desktop";
              "application/x-rar" = "org.gnome.FileRoller.desktop";
              "application/x-tar" = "org.gnome.FileRoller.desktop";
              "application/x-xz" = "org.gnome.FileRoller.desktop";
              "application/zip" = "org.gnome.FileRoller.desktop";
              "image/*" = [ "feh.desktop" ];
              "inode/directory" = "dev.duxlabs.files.desktop";
              "text/plain" = "neovim.desktop";
              "video/*" = "mpv.desktop";
              "video/*,.mkv" = "mpv.desktop";
              "video/3gpp" = "mpv.desktop";
              "video/3gpp2" = "mpv.desktop";
              "video/avi" = "mpv.desktop";
              "video/mp4" = "mpv.desktop";
              "video/mpeg" = "mpv.desktop";
              "video/ogg" = "mpv.desktop";
              "video/quicktime" = "mpv.desktop";
              "video/webm" = "mpv.desktop";
              "video/x-flv" = "mpv.desktop";
              "video/x-m4v" = "mpv.desktop";
              "video/x-matroska" = "mpv.desktop";
              "video/x-ms-asf" = "mpv.desktop";
              "video/x-ms-wmv" = "mpv.desktop";
              "video/x-msvideo" = "mpv.desktop";
              "video/x-ogm+ogg" = "mpv.desktop";
              "video/x-theora+ogg" = "mpv.desktop";
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
