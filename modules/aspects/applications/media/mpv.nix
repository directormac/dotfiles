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
          echo -e "╭── MPV History Entry ─────────────────────────────"
          echo -e "│ File:     $file"
          echo -e "│ Watched:  $date"
          echo -e "│ Duration: $dur"
          if [ -f "$file" ]; then
            echo -e "├── File Details ──────────────────────────────────"
            ls -lh "$file" 2>/dev/null | awk '{print "│ Size:     " $5 "\n│ Modified: " $6 " " $7 " " $8}'
          fi
          echo -e "├── Actions ───────────────────────────────────────"
          echo -e "│ • Enter:  Play file in MPV"
          echo -e "│ • Ctrl-q: Add to active MPV playlist"
          echo -e "│ • Ctrl-y: Copy file path to clipboard"
          echo -e "╰──────────────────────────────────────────────────"
        '';
        tv-mpv-playlist = pkgs.writeShellScriptBin "tv-mpv-playlist" ''
          ${pkgs.television}/bin/tv mpv-playlist
        '';
        tv-mpv-playlist-preview = pkgs.writeShellScript "tv-mpv-playlist-preview" ''
          idx="$1"
          title="$2"
          file="$3"
          echo -e "╭── MPV Playlist Track: #$idx ────────────────────────"
          echo -e "│ Title:    $title"
          echo -e "│ Path/URL: $file"
          echo -e "├── Live Player Status ────────────────────────────"
          ${pkgs.mpvc}/bin/mpvc -f "│ Status:   %status% | Track %position%/%playlistlength% | %time%/%length% (%percentage%%)\n│ Volume:   %volume%% (Muted: %muted%)\n│ Track:    %artist% - %title%" 2>/dev/null || echo "│ (Unable to query live playback stats)"
          echo -e "├── Keybindings ───────────────────────────────────"
          echo -e "│ • Enter:   Jump & play this track"
          echo -e "│ • Ctrl-p:  Toggle Play/Pause"
          echo -e "│ • Ctrl-d:  Remove from playlist"
          echo -e "│ • Ctrl-s:  Stop playback"
          echo -e "│ • Ctrl-y:  Copy track URL/path"
          echo -e "╰──────────────────────────────────────────────────"
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
          echo -e "╭── Video: $title ──────────────────────────"
          echo -e "│ Channel:  $channel"
          echo -e "│ Duration: $duration"
          echo -e "│ Video ID: $id"
          echo -e "│ URL:      $url"
          echo -e "├── Actions ───────────────────────────────"
          echo -e "│ • Enter:  Download best quality video"
          echo -e "│ • Ctrl-a: Download audio only (mp3)"
          echo -e "│ • Ctrl-p: Stream directly in MPV"
          echo -e "│ • Ctrl-q: Add to active MPV playlist"
          echo -e "│ • Ctrl-y: Copy video URL"
          echo -e "╰──────────────────────────────────────────"
        '';
      in
      {
        home.packages = [
          pkgs.mpvc
          pkgs.socat
          pkgs.trash-cli
          tv-ytdl
          tv-mpv-playlist
        ];

        programs.mpv = {
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

          enable = true;

          package = pkgs.mpv.override {
            mpv-unwrapped = pkgs.mpv-unwrapped.override {
              ffmpeg = pkgs.ffmpeg-full;
              waylandSupport = true;
            };

            scripts = with pkgs.mpvScripts; [
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
            command = "${tv-mpv-history-preview} '{split:\t:0}' '{split:\t:1}' '{}'"

            [keybindings]
            enter = "actions:play"
            ctrl-q = "actions:queue"
            ctrl-y = "actions:copy"

            [actions.play]
            description = "Play file in MPV"
            command = "mpv '{}'"
            mode = "fork"

            [actions.queue]
            description = "Add file to active MPV playlist"
            command = "${pkgs.mpvc}/bin/mpvc -a '{}'"
            mode = "execute"

            [actions.copy]
            description = "Copy file path to clipboard"
            command = "echo -n '{}' | wl-copy"
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
            ctrl-p = "actions:toggle"
            ctrl-d = "actions:remove"
            ctrl-s = "actions:stop"
            ctrl-n = "actions:next"
            ctrl-b = "actions:prev"
            ctrl-y = "actions:copy"

            [actions.play]
            description = "Jump to and play this playlist track"
            command = "${pkgs.mpvc}/bin/mpvc -J '{}'"
            mode = "execute"

            [actions.toggle]
            description = "Toggle play/pause"
            command = "${pkgs.mpvc}/bin/mpvc -p"
            mode = "execute"

            [actions.remove]
            description = "Remove track from playlist"
            command = "echo '{\"command\": [\"playlist-remove\", {}]}' | ${pkgs.socat}/bin/socat - /tmp/mpvsocket 2>/dev/null"
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
            command = "url=\"''${YT_URL:-$(wl-paste 2>/dev/null)}\"; if [ -z \"$url\" ]; then url=\"ytsearch20:nixos linux\"; fi; yt-dlp \"$url\" --flat-playlist --print '%(id)s\t%(title)s\t%(uploader)s\t%(duration_string)s\t%(webpage_url)s' 2>/dev/null"
            display = "{split:\t:1}  │  {split:\t:2}  ({split:\t:3})"
            output = "{split:\t:4}"

            [preview]
            command = "${tv-ytdl-preview} '{split:\t:0}' '{split:\t:1}' '{split:\t:2}' '{split:\t:3}' '{}'"

            [keybindings]
            enter = "actions:download"
            ctrl-a = "actions:download_audio"
            ctrl-p = "actions:stream_mpv"
            ctrl-q = "actions:queue_mpv"
            ctrl-y = "actions:copy_url"

            [actions.download]
            description = "Download best quality video to ~/Downloads"
            command = "yt-dlp -P \"~/Downloads\" '{}'"
            mode = "execute"

            [actions.download_audio]
            description = "Extract and download audio (mp3) to ~/Downloads"
            command = "yt-dlp -x --audio-format mp3 -P \"~/Downloads\" '{}'"
            mode = "execute"

            [actions.stream_mpv]
            description = "Stream video in MPV"
            command = "mpv '{}'"
            mode = "fork"

            [actions.queue_mpv]
            description = "Add video to active MPV playlist"
            command = "${pkgs.mpvc}/bin/mpvc -a '{}'"
            mode = "execute"

            [actions.copy_url]
            description = "Copy video URL to clipboard"
            command = "echo -n '{}' | wl-copy"
            mode = "execute"
          '';
      };

    persistHome.directories = [
      ".config/mpv"
      ".config/mpvc"
    ];
  };
}
