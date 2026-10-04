{ self, ... }:
{
  flake.homeModules.xdg =
    { pkgs, config, ... }:
    {

      # https://home-manager-options.extranix.com/?query=xdg&release=master
      xdg = {
        enable = true;
        userDirs = {
          enable = true;
          createDirectories = true;

          extraConfig = {
            XDG_CODE_DIR = "${config.home.homeDirectory}/Code";
            XDG_WORK_DIR = "${config.home.homeDirectory}/Work";
          };
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

            "application/zip" = "org.gnome.FileRoller.desktop";
            "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
            "application/x-tar" = "org.gnome.FileRoller.desktop";
            "application/x-bzip2" = "org.gnome.FileRoller.desktop";
            "application/x-gzip" = "org.gnome.FileRoller.desktop";
            "application/x-xz" = "org.gnome.FileRoller.desktop";
            "application/x-rar" = "org.gnome.FileRoller.desktop";
            "application/rar" = "org.gnome.FileRoller.desktop";
          };

          associations.added = {
            "text/plain" = [ "neovim.desktop" ];
            "inode/directory" = [ "superfile.desktop" ];
            "video/*" = [
              "mpv.desktop"
              "vlc-new-window.desktop"
              "vlc-enqueue.desktop"
            ];
            "audio/*" = [
              "mpv.desktop"
              "vlc-new-window.desktop"
              "vlc-enqueue.desktop"
            ];
          };

        };

        desktopEntries = {

          superfile = {
            name = "Superfile";
            genericName = "Terminal File Manager";
            exec = "ghostty --class=com.superfile.fm -e superfile %F"; # 'spf' is the binary command for superfile
            terminal = false;
            type = "Application";
            icon = "utilities-terminal";
            mimeType = [ "inode/directory" ];

            categories = [
              "System"
              "FileManager"
              "Utility"
              "Core"
            ];

            actions = {
              "open-in-superfile" = {
                name = "Open in Superfile";
                exec = "ghostty --class=com.superfile.fm -e superfile %f";

              };
            };

          };

          gsmartcontrol = {
            name = "GSmartControl";
            exec = "gsmartcontrol"; # Explicitly use the non-root binary
            icon = "gsmartcontrol";
            terminal = false;
            categories = [
              "System"
              "Utility"
            ];
            type = "Application";
          };

          vlc-new-window = {
            name = "Open in New VLC Window";
            genericName = "Media Player (New Window)";
            exec = "vlc --no-one-instance --no-one-instance-when-started-from-file %U";
            icon = "vlc";
            terminal = false;
            type = "Application";
            categories = [
              "AudioVideo"
              "Player"
            ];
            mimeType = [
              "video/*"
              "audio/*"
            ];
          };

          vlc-enqueue = {
            name = "Add to VLC Playlist";
            genericName = "Media Player (Enqueue)";
            exec = "vlc --one-instance --playlist-enqueue %U";
            icon = "vlc";
            terminal = false;
            type = "Application";
            categories = [
              "AudioVideo"
              "Player"
            ];
            mimeType = [
              "video/*"
              "audio/*"
            ];
          };

        };

        portal = {
          enable = true;
          xdgOpenUsePortal = true;
          config = {
            common = {
              default = [ "gtk" ];
              # Force every app outside native DEs to use the GTK fallback dialog
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
              "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
              "org.freedesktop.impl.portal.RemoteDesktop" = [ "hypr_kdeconnect" ];
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
              "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
              "org.freedesktop.impl.portal.Access" = [ "gtk" ];
              "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
              "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
              "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
              "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
            };
            mango = {
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
            # pkgs.xdg-desktop-portal
            pkgs.xdg-desktop-portal-gtk
            pkgs.xdg-desktop-portal-gnome
            pkgs.xdg-desktop-portal-hyprland
            pkgs.kdePackages.xdg-desktop-portal-kde
            pkgs.xdg-desktop-portal-wlr
            self.packages.${pkgs.stdenv.hostPlatform.system}.hypr-kdeconnect-fix
          ];
        };
      };

      home.file = {
        ".face".source = config.lib.file.mkOutOfStoreSymlink "/home/artifex/.dotfiles/config/.face";
        ".config/wallpapers".source =
          config.lib.file.mkOutOfStoreSymlink "/home/artifex/.dotfiles/config/wallpapers";
      };

      gtk = {
        enable = true;
        gtk3.bookmarks = [
          "file://${config.home.homeDirectory}/Code Code"
          "file://${config.home.homeDirectory}/Projects Projects"
          "file://${config.home.homeDirectory}/Downloads Downloads"
          "file:///mnt/local/resources Resources(SSD)"
          "file:///mnt/network/fileserver Fileserver"
        ];
      };

      dconf.settings = {
        "org/gnome/desktop/privacy" = {
          remember-recent-files = false;
        };
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

    # Necessary for xdg-portal home-manager module to work with useUserPackages
    environment.pathsToLink = [
      "/share/xdg-desktop-portal"
      "/share/applications"
    ];

  };

}
