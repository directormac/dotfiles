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
          };

          associations.added = {
            "text/plain" = [ "neovim.desktop" ];
          };

        };

        desktopEntries = {
          yazi = {
            name = "Yazi";
            genericName = "Terminal File Manager";
            exec = "ghostty --class=com.yazi.fm -e yazi";
            terminal = false;
            type = "Application";
            icon = "yazi";
            categories = [
              "Utility"
              "Core"
            ];

            # Define custom right-click context menu actions
            actions = {
              "open-terminal" = {
                name = "Open Terminal Here";
                exec = "ghostty --working-directory=%f";
              };
            };
          };

          superfile = {
            name = "Superfile";
            genericName = "Terminal File Manager";
            exec = "ghostty --class=com.superfile.fm -e spf"; # 'spf' is the binary command for superfile
            terminal = false;
            type = "Application";
            icon = "superfile"; # Ensure you have an icon assigned or change to a generic name
            categories = [
              "Utility"
              "Core"
            ];

            actions = {
              "open-terminal" = {
                name = "Open Terminal Here";
                exec = "ghostty --working-directory=%f";
              };
            };
          };

          # gsmartcontrol = {
          #   name = "GSmartControl (Stylix Fix)";
          #   genericName = "Hard Disk Health Monitor";
          #   comment = "Query and control SMART data on storage systems";
          #   icon = "gsmartcontrol";
          #
          #   # Wrap the execution sequence in a shell string to bypass validation checks
          #   exec = "sh -c 'sudo env WAYLAND_DISPLAY=$WAYLAND_DISPLAY XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR XDG_CONFIG_HOME=$HOME/.config gsmartcontrol'";
          #
          #   terminal = true;
          #   categories = [
          #     "System"
          #     "Monitor"
          #   ];
          # };

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
        "org/gnome/nautilus/preferences" = {
          # Keep folders at the very top of the window when sorting by name/date
          sort-directories-first = true;

          # Changes the default behavior when clicking on a file name to change it.
          # Selecting a file and typing will rename it in-place instead of opening a distinct modal window.
          rename-with-inline-handler = true;

          # Change default archiving/compression tool choice from .tar.xz to standard zip
          default-compression-format = "zip";

          # "always" forces thumbnails on local drives AND your network mounted samba/nfs paths
          show-image-thumbnails = "always";

          # Increases or completely removes the max file size limitation for previews (in bytes)
          # 0 means unrestricted: it will even thumbnail a 4GB movie file!
          thumbnail-limit = 0;
        };
        "org/gnome/desktop/thumbnail-cache" = {
          # Set the maximum size of the thumbnail cache folder in Megabytes (MB)
          # 512 is the default. Let's strictly cap it at 1024 MB (1GB) so it never hogs your storage.
          maximum-size = 1024;

          # Set the maximum lifetime of cached files in days.
          # Any thumbnail that hasn't been previewed for 30 days gets cleanly deleted.
          maximum-age = 30;
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
    xdg.portal = {
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
