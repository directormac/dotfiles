{ self, lib, ... }: {

  flake.homeModules.nautilus =
    { pkgs, config, ... }:
    {
      xdg.dataFile = {
        "nautilus/scripts/Play with mpv" = {
          executable = true;
          text = ''
            #!/usr/bin/env bash
            export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"
            exec mpv "$@"
          '';
        };

        "nautilus/scripts/Open in Superfile" = {
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

        "nautilus/scripts/Compress with File Roller" = {
          executable = true;
          text = ''
            #!/usr/bin/env bash
            export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"
            file-roller -d "$@"
          '';
        };

        "nautilus/scripts/Extract Here (File Roller)" = {
          executable = true;
          text = ''
            #!/usr/bin/env bash
            export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"
            file-roller -h "$@"
          '';
        };

        "nautilus/scripts/Open in New VLC Window" = {
          executable = true;
          text = ''
            #!/usr/bin/env bash
            export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"
            exec vlc --no-one-instance --no-one-instance-when-started-from-file "$@"
          '';
        };

        "nautilus/scripts/Add to VLC Playlist" = {
          executable = true;
          text = ''
            #!/usr/bin/env bash
            export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"
            exec vlc --one-instance --playlist-enqueue "$@"
          '';
        };

        "nautilus-python/extensions/open_in_superfile.py".text = ''
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

        "nautilus-python/extensions/vlc_actions.py".text = ''
          import subprocess
          from gi.repository import Nautilus, GObject

          class VlcExtension(GObject.GObject, Nautilus.MenuProvider):
              def _is_media(self, file_item):
                  if file_item.is_directory():
                      return False
                  mimetype = file_item.get_mime_type()
                  if mimetype and (mimetype.startswith("video/") or mimetype.startswith("audio/")):
                      return True
                  name = file_item.get_name().lower()
                  return name.endswith((
                      ".mp4", ".mkv", ".avi", ".mov", ".flv", ".webm", ".wmv",
                      ".m4v", ".mp3", ".flac", ".wav", ".ogg", ".opus", ".m4a", ".aac"
                  ))

              def _get_paths(self, files):
                  paths = []
                  for f in files:
                      loc = f.get_location()
                      if loc:
                          p = loc.get_path()
                          if p:
                              paths.append(p)
                  return paths

              def _open_new_window(self, menu, files):
                  paths = self._get_paths(files)
                  if paths:
                      subprocess.Popen(["vlc", "--no-one-instance", "--no-one-instance-when-started-from-file"] + paths)

              def _enqueue(self, menu, files):
                  paths = self._get_paths(files)
                  if paths:
                      subprocess.Popen(["vlc", "--one-instance", "--playlist-enqueue"] + paths)

              def get_file_items(self, *args):
                  files = args[-1]
                  media_files = [f for f in files if self._is_media(f)]
                  if not media_files:
                      return []

                  item_new = Nautilus.MenuItem(
                      name="VlcExtension::open_new_window",
                      label="Open in New VLC Window",
                      tip="Open selected media in a new VLC window",
                      icon="vlc"
                  )
                  item_new.connect("activate", self._open_new_window, media_files)

                  item_enqueue = Nautilus.MenuItem(
                      name="VlcExtension::enqueue",
                      label="Add to VLC Playlist",
                      tip="Enqueue selected media in the running VLC instance",
                      icon="vlc"
                  )
                  item_enqueue.connect("activate", self._enqueue, media_files)

                  return [item_new, item_enqueue]
        '';

        "nautilus-python/extensions/mpv_actions.py".text = ''
          import subprocess
          from gi.repository import Nautilus, GObject

          class MpvExtension(GObject.GObject, Nautilus.MenuProvider):
              def _is_media(self, file_item):
                  if file_item.is_directory():
                      return False
                  mimetype = file_item.get_mime_type()
                  if mimetype and (mimetype.startswith("video/") or mimetype.startswith("audio/")):
                      return True
                  name = file_item.get_name().lower()
                  return name.endswith((
                      ".mp4", ".mkv", ".avi", ".mov", ".flv", ".webm", ".wmv",
                      ".m4v", ".mp3", ".flac", ".wav", ".ogg", ".opus", ".m4a", ".aac"
                  ))

              def _get_paths(self, files):
                  paths = []
                  for f in files:
                      loc = f.get_location()
                      if loc:
                          p = loc.get_path()
                          if p:
                              paths.append(p)
                  return paths

              def _play_with_mpv(self, menu, files):
                  paths = self._get_paths(files)
                  if paths:
                      subprocess.Popen(["mpv"] + paths)

              def get_file_items(self, *args):
                  files = args[-1]
                  media_files = [f for f in files if self._is_media(f)]
                  if not media_files:
                      return []

                  item_play = Nautilus.MenuItem(
                      name="MpvExtension::play",
                      label="Play with mpv",
                      tip="Play selected media with mpv",
                      icon="mpv"
                  )
                  item_play.connect("activate", self._play_with_mpv, media_files)

                  return [item_play]
        '';
      };

      dconf.settings = {
        "org/gnome/nautilus/preferences" = {
          # Keep folders at the very top of the window when sorting by name/date
          sort-directories-first = true;

          # Selecting a file and typing will rename it in-place
          rename-with-inline-handler = true;

          # Change default archiving/compression tool choice from .tar.xz to standard zip
          default-compression-format = "zip";

          # "always" forces thumbnails on local drives AND network mounted samba/nfs paths
          show-image-thumbnails = "always";

          # 0 means unrestricted: will thumbnail even large video files
          thumbnail-limit = 0;
        };

        "org/gnome/desktop/thumbnail-cache" = {
          # Cap thumbnail cache at 1024 MB
          maximum-size = 1024;
          # 30 days max lifetime
          maximum-age = 30;
        };
      };
    };

  flake.nixosModules.nautilus =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      home-manager.users.${config.preferences.user.name} = {
        imports = [
          self.homeModules.nautilus
        ];
      };

      programs.nautilus-open-any-terminal = {
        enable = true;
        terminal = "ghostty";
      };

      environment.sessionVariables = {
        NAUTILUS_4_EXTENSION_DIR = lib.mkForce "/run/current-system/sw/lib/nautilus/extensions-4";
      };

      environment.pathsToLink = [
        "share/thumbnailers"
        "/lib/nautilus/extensions-4"
        "/share/nautilus-python/extensions"
      ];

      environment.systemPackages = with pkgs; [
        nautilus
        nautilus-python
        nautilus-open-any-terminal
        sushi
        file-roller
        p7zip

        # High-performance thumbnailers
        ffmpegthumbnailer # Video thumbs (MKV, MP4, HEVC, AV1)
        gdk-pixbuf # Raw image asset translations
        webp-pixbuf-loader # .webp images
        poppler-utils # PDF thumbnails
        libgsf # ODF and open-office document formats
        libjxl # JPEG-XL
      ];
    };

}
