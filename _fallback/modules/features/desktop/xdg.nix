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

        dataFile."nautilus/scripts/Open in Superfile" = {
          executable = true;
          text = ''
            #!/usr/bin/env bash
            export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"
            TARGET=""
            if [ -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" ]; then
              TARGET="$(printf '%s\n' "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | head -n 1)"
            fi
            if [ -z "$TARGET" ]; then
              TARGET="$PWD"
            fi
            if [ -f "$TARGET" ]; then
              TARGET="$(dirname "$TARGET")"
            fi
            exec ghostty --class=com.superfile.fm -e superfile "$TARGET"
          '';
        };

        dataFile."nautilus/scripts/Compress with File Roller" = {
          executable = true;
          text = ''
            #!/usr/bin/env bash
            export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"
            file-roller -d "$@"
          '';
        };

        dataFile."nautilus/scripts/Extract Here (File Roller)" = {
          executable = true;
          text = ''
            #!/usr/bin/env bash
            export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"
            file-roller -h "$@"
          '';
        };

        dataFile."nautilus-python/extensions/open_in_superfile.py".text = ''
          import subprocess
          from gi.repository import Nautilus, GObject

          class SuperfileExtension(GObject.GObject, Nautilus.MenuProvider):
              def _launch(self, path):
                  subprocess.Popen(["ghostty", "--class=com.superfile.fm", "-e", "superfile", path])

              def _activate(self, menu, file_item):
                  loc = file_item.get_location()
                  if loc:
                      path = loc.get_path()
                      if path:
                          self._launch(path)

              def get_file_items(self, *args):
                  files = args[-1]
                  if len(files) == 1 and files[0].is_directory():
                      item = Nautilus.MenuItem(
                          name="Superfile::open_folder",
                          label="Open in Superfile",
                          tip="Open selected folder in Superfile",
                          icon="utilities-terminal"
                      )
                      item.connect("activate", self._activate, files[0])
                      return [item]
                  return []

              def get_background_items(self, *args):
                  folder = args[-1]
                  item = Nautilus.MenuItem(
                      name="Superfile::open_bg",
                      label="Open in Superfile",
                      tip="Open current folder in Superfile",
                      icon="utilities-terminal"
                  )
                  item.connect("activate", self._activate, folder)
                  return [item]
        '';

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

    # Necessary for xdg-portal home-manager module to work with useUserPackages
    environment.pathsToLink = [
      "/share/xdg-desktop-portal"
      "/share/applications"
    ];

  };

}
