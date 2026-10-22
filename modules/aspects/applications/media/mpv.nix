# MPV Media Player Leaf Aspect with stax76 Scripts, mpvc Control, and Television Channels
{
  den.aspects.applications.media.mpv = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          ffmpeg-full
          mpv
          socat
          trash-cli
        ];
      };

    homeManager =
      { lib, pkgs, ... }:
      let
        mkStaxScript =
          name:
          pkgs.stdenv.mkDerivation {
            dontBuild = true;

            installPhase = ''
              mkdir -p $out/share/mpv/scripts
              cp ${name}.lua $out/share/mpv/scripts/
            '';

            passthru.scriptName = "${name}.lua";
            pname = "mpv-stax76-${name}";
            src = stax76-src;
            version = "unstable-2024-09-02";
          };
        mpv-enqueue = pkgs.writeShellScriptBin "mpv-enqueue" ''
          SOCKET="/tmp/mpvsocket"
          if [ -S "$SOCKET" ] && echo '{ "command": ["get_property", "idle"] }' | ${pkgs.socat}/bin/socat - "$SOCKET" >/dev/null 2>&1; then
            for file in "$@"; do
              if [[ "$file" =~ ^[a-zA-Z0-9_-]+:// ]]; then
                url="$file"
              else
                url="$(readlink -f "$file" 2>/dev/null || realpath "$file" 2>/dev/null || echo "$file")"
              fi
              esc_url=$(printf '%s' "$url" | sed 's/\\/\\\\/g; s/"/\\"/g')
              echo "{\"command\": [\"loadfile\", \"$esc_url\", \"append-play\"]}" | ${pkgs.socat}/bin/socat - "$SOCKET" 2>/dev/null
            done
          else
            exec mpv "$@"
          fi
        '';
        stax76-src = pkgs.fetchFromGitHub {
          hash = "sha256-qEw0T/37n8aQ2WU4YsxCjJGdoa2Ft3Vg6y6jGWAnJDM=";
          owner = "stax76";
          repo = "mpv-scripts";
          rev = "93ecede23195c281669df98fcacc4e7919c8f2fb";
        };
        tv-mpv-history-preview = pkgs.writeShellScript "tv-mpv-history-preview" ''
          date="$1"
          dur="$2"
          file="$3"

          echo "$file"
          echo "watched: $date ($dur mins)"
          if [ -f "$file" ]; then
            echo ""
            echo "file details"
            ls -lh "$file" 2>/dev/null | awk '{print "size:     " $5 "\nmodified: " $6 " " $7 " " $8}'
          fi
        '';
        tv-mpv-playlist = pkgs.writeShellScriptBin "tv-mpv-playlist" ''
          ${pkgs.television}/bin/tv mpv-playlist
        '';
        tv-mpv-playlist-preview = pkgs.writeShellScript "tv-mpv-playlist-preview" ''
          idx="$1"
          title="$2"
          file="$3"

          echo "#$idx: $title"
          echo "$file"

          status=$(${pkgs.mpvc}/bin/mpvc -f "%status% | %position%/%playlistlength% | %time%/%length% (%percentage%%) | vol %volume%%" 2>/dev/null || true)
          if [ -n "$status" ]; then
            echo ""
            echo "status"
            echo "$status"
          fi
        '';
        tv-mpv-playlist-source = pkgs.writeShellScript "tv-mpv-playlist-source" ''
          ${pkgs.python3}/bin/python3 -c '
          import socket, json
          try:
              s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
              s.settimeout(0.8)
              s.connect("/tmp/mpvsocket")
              s.sendall(b"{\"command\": [\"get_property\", \"playlist\"]}\n")
              data = b""
              while True:
                  chunk = s.recv(4096)
                  if not chunk:
                      break
                  data += chunk
                  if b"\n" in chunk:
                      break
              s.close()
              res = json.loads(data.decode("utf-8", errors="replace"))
              items = res.get("data", [])
              for i, item in enumerate(items):
                  current = item.get("current", False)
                  indicator = "▶" if current else " "
                  filename = item.get("filename", "")
                  title = item.get("title") or filename.split("/")[-1]
                  print(f"{i}\t{indicator}\t{title}\t{filename}")
          except Exception:
              pass
          '
        '';
        tv-ytdl = pkgs.writeShellScriptBin "tv-ytdl" ''
          target="$1"
          if [ -z "$target" ]; then
            clip=$(${pkgs.wl-clipboard}/bin/wl-paste 2>/dev/null)
            if [[ "$clip" =~ ^https?:// ]]; then
              target="$clip"
              echo "Using URL from clipboard: $target"
            fi
          fi
          if [ -z "$target" ]; then
            read -rp "Enter video/playlist URL or search query: " target
          fi
          if [ -z "$target" ]; then
            echo "Error: No URL or search query provided." >&2
            exit 1
          fi

          if [[ ! "$target" =~ ^https?:// ]]; then
            target="ytsearch25:$target"
          fi

          YT_URL="$target" ${pkgs.television}/bin/tv yt-dlp
        '';
        tv-ytdl-preview = pkgs.writeShellScript "tv-ytdl-preview" ''
          id="$1"
          title="$2"
          channel="$3"
          duration="$4"
          url="$5"

          echo "$title"
          [ -n "$channel" ] && echo "channel:  $channel"
          [ -n "$duration" ] && echo "duration: $duration"
          [ -n "$id" ] && echo "id:       $id"
          if [ -n "$url" ]; then
            echo ""
            echo "url"
            echo "$url"
          fi
        '';
        tv-ytdl-source = pkgs.writeShellScript "tv-ytdl-source" ''
          url="''${YT_URL:-}"
          if [ -z "$url" ]; then
            clip=$(${pkgs.wl-clipboard}/bin/wl-paste 2>/dev/null || true)
            if [[ "$clip" =~ ^https?://[^[:space:]]+$ ]]; then
              url="$clip"
            fi
          fi

          if [ -z "$url" ]; then
            url="ytsearch20:nixos linux"
          elif [[ ! "$url" =~ ^https?:// ]] && [[ ! "$url" =~ ^[a-z]+search[0-9]*: ]]; then
            url="ytsearch20:$url"
          fi

          exec ${pkgs.yt-dlp}/bin/yt-dlp "$url" \
            --flat-playlist \
            --no-warnings \
            --print '%(id)s	%(title)s	%(uploader)s	%(duration_string)s	%(webpage_url)s' \
            2>/dev/null
        '';
      in
      {
        home.packages = [
          mpv-enqueue
          pkgs.mpvc
          pkgs.socat
          pkgs.trash-cli
          tv-ytdl
          tv-mpv-playlist
        ];

        programs.mpv = {
          enable = true;

          bindings = {
            "DEL" = "script-message-to delete_current_file delete-file";
            "ctrl+V" = "script-message-to misc load-from-clipboard append";
            "ctrl+v" = "script-message-to misc load-from-clipboard replace";
            "i" = "script-message-to misc print-media-info";
          };

          config = {
            border = false;
            cache = "yes";
            demuxer-max-bytes = "400M";
            input-ipc-server = "/tmp/mpvsocket";
            osc = false;
            profile = "high-quality";
            ytdl-format = "bestvideo+bestaudio";
          };

          package = pkgs.mpv.override {
            mpv-unwrapped = pkgs.mpv-unwrapped.override {
              ffmpeg = pkgs.ffmpeg-full;
              waylandSupport = true;
            };

            scripts = with pkgs.mpvScripts; [
              mpris
              autoload
              autosub
              modernx-zydezu
              mpv-playlistmanager
              quality-menu
              sponsorblock
              thumbfast
              videoclip
              webtorrent-mpv-hook
              youtube-upnext
              mpv-webm
              (mkStaxScript "history")
              (mkStaxScript "delete_current_file")
              (mkStaxScript "misc")
              (mkStaxScript "auto_mode")
              (mkStaxScript "average_volume")
            ];
          };
        };

        stylix.targets.mpv.enable = lib.mkDefault true;

        xdg.configFile."mpvc/mpvc.conf".text = ''
          MPVC_SOCKET="/tmp/mpvsocket"
        '';

        xdg.configFile."television/cable/mpv-history.toml".text =
          # toml
          ''
            [metadata]
            name = "mpv-history"
            description = "Browse and replay previously watched videos logged by history.lua"

            [source]
            command = "cat ~/.config/mpv/history.log 2>/dev/null | tac | awk '{date=$1\" \"$2; mins=$3; $1=\"\"; $2=\"\"; $3=\"\"; sub(/^   /, \"\"); print date \"\\t\" mins \"m\\t\" $0}'"
            display = "[{split:\t:0}] {split:\t:1}  │  {split:\t:2}"
            output = "{split:\t:2}"

            [preview]
            command = "${tv-mpv-history-preview} '{split:\t:0}' '{split:\t:1}' '{split:\t:2}'"

            [keybindings]
            enter = "actions:play"
            ctrl-q = "actions:queue"
            ctrl-y = "actions:copy"

            [actions.play]
            description = "Play file in MPV"
            command = "mpv '{split:\t:2}'"
            mode = "fork"

            [actions.queue]
            description = "Add file to active MPV playlist"
            command = "${pkgs.mpvc}/bin/mpvc -a '{split:\t:2}'"
            mode = "execute"

            [actions.copy]
            description = "Copy file path to clipboard"
            command = "echo -n '{split:\t:2}' | wl-copy"
            mode = "execute"
          '';

        xdg.configFile."television/cable/mpv-playlist.toml".text =
          # toml
          ''
            [metadata]
            name = "mpv-playlist"
            description = "View, fuzzy search, and control the active MPV playlist"
            requirements = ["mpvc", "python3"]

            [source]
            command = "${tv-mpv-playlist-source}"
            display = "{split:\t:1} [{split:\t:0}]  {split:\t:2}"
            output = "{split:\t:0}"

            [preview]
            command = "${tv-mpv-playlist-preview} '{split:\t:0}' '{split:\t:2}' '{split:\t:3}'"

            [keybindings]
            enter = "actions:play"
            ctrl-q = "actions:toggle"
            ctrl-d = "actions:remove"
            ctrl-b = "actions:prev"
            ctrl-y = "actions:copy"
            [actions.play]
            description = "Jump to and play this playlist track"
            command = "${pkgs.mpvc}/bin/mpvc -J '{split:\t:0}'"
            mode = "execute"

            [actions.toggle]
            description = "Toggle play/pause"
            command = "${pkgs.mpvc}/bin/mpvc -p"
            mode = "execute"

            [actions.remove]
            description = "Remove track from playlist"
            command = "echo '{\"command\": [\"playlist-remove\", {split:\t:0}]}' | ${pkgs.socat}/bin/socat - /tmp/mpvsocket 2>/dev/null"
            mode = "execute"
            [actions.stop]
            description = "Stop playback"
            command = "${pkgs.mpvc}/bin/mpvc -s"
            mode = "execute"

            [actions.next]
            description = "Next track"
            command = "${pkgs.mpvc}/bin/mpvc --next"
            mode = "execute"

            [actions.prev]
            description = "Previous track"
            command = "${pkgs.mpvc}/bin/mpvc --prev"
            mode = "execute"

            [actions.copy]
            description = "Copy track path/URL to clipboard"
            command = "echo -n '{split:\t:3}' | wl-copy"
            mode = "execute"
          '';

        xdg.configFile."television/cable/yt-dlp.toml".text =
          # toml
          ''
            [metadata]
            name = "yt-dlp"
            description = "Search and fuzzyfind videos/playlists to stream in MPV or download with yt-dlp"
            requirements = ["yt-dlp"]

            [source]
            command = "${tv-ytdl-source}"
            display = "{split:\t:1}  │  {split:\t:2}  ({split:\t:3})"
            output = "{split:\t:4}"

            [preview]
            command = "${tv-ytdl-preview} '{split:\t:0}' '{split:\t:1}' '{split:\t:2}' '{split:\t:3}' '{split:\t:4}'"

            [keybindings]
            enter = "actions:stream_mpv"
            ctrl-d = "actions:download"
            ctrl-q = "actions:queue_mpv"
            ctrl-y = "actions:copy_url"
            [actions.download]
            description = "Download best quality video to ~/Downloads"
            command = "yt-dlp -P \"$HOME/Downloads\" '{split:\t:4}'"

            [actions.download_audio]
            description = "Extract and download audio (mp3) to ~/Downloads"
            command = "yt-dlp -x --audio-format mp3 -P \"$HOME/Downloads\" '{split:\t:4}'"

            [actions.stream_mpv]
            description = "Stream video in MPV"
            command = "mpv '{split:\t:4}'"
            mode = "fork"

            [actions.queue_mpv]
            description = "Add video to active MPV playlist"
            command = "${pkgs.mpvc}/bin/mpvc -a '{split:\t:4}'"
            mode = "execute"

            [actions.copy_url]
            description = "Copy video URL to clipboard"
            command = "echo -n '{split:\t:4}' | wl-copy"
            mode = "execute"
          '';

        xdg.desktopEntries = {
          mpv-enqueue = {
            categories = [
              "AudioVideo"
              "Player"
            ];

            exec = "mpv-enqueue %U";
            genericName = "Media Player (Enqueue)";
            icon = "mpv";

            mimeType = [
              "video/*"
              "audio/*"
            ];

            name = "Add to mpv Playlist";
            terminal = false;
            type = "Application";
          };

          mpv-new-window = {
            categories = [
              "AudioVideo"
              "Player"
            ];

            exec = "mpv --input-ipc-server= %U";
            genericName = "Media Player (New Window)";
            icon = "mpv";

            mimeType = [
              "video/*"
              "audio/*"
            ];

            name = "Open in New mpv Window";
            terminal = false;
            type = "Application";
          };
        };
      };

    persistHome.directories = [
      ".config/mpv"
      ".config/mpvc"
    ];
  };
}
