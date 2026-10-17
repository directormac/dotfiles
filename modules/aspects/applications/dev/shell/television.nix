# Television Fuzzy Finder Aspect with Custom Cables and Cache Update Timer
{
  den.aspects.applications.dev.shell.television = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages =
          with pkgs;
          [
            television
            nix-search-tv
            jq
          ]
          ++ (lib.optionals (pkgs ? local) (
            with pkgs.local;
            [
              rebuild-switch
              nix-generations
            ]
          ));
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
        tv-channel-enter = pkgs.writeShellScript "tv-channel-enter" ''
          chan="$1"
          if [ -n "$TV_CMD" ]; then
            cmd_args="''${TV_CMD#tv }"
            exec ${pkgs.television}/bin/tv $cmd_args "$chan"
          else
            exec ${pkgs.television}/bin/tv "$chan"
          fi
        '';
        tv-histdb-preview = pkgs.writeShellScript "tv-histdb-preview" ''
                    cmd="$1"
                    last_run="$2"
                    last_dir="$3"
                    db="''${HISTDB_FILE:-$HOME/.local/share/zsh/history.db}"

                    echo -e "╭── Command: $cmd ─────────────────────────────────"
                    if [ -n "$last_run" ] && [ "$last_run" != "-" ]; then
                      echo -e "│ Last run:  $last_run"
                    fi
                    if [ -n "$last_dir" ] && [ "$last_dir" != "~" ]; then
                      echo -e "│ Directory: $last_dir"
                    fi

                    if [ -f "$db" ] && [ -n "$cmd" ]; then
                      echo -e "├── Recent Runs (zsh-histdb) ──────────────────────"
                      ${pkgs.python3}/bin/python3 -c '
          import sys, sqlite3
          db_path, cmd = sys.argv[1], sys.argv[2]
          try:
              conn = sqlite3.connect(db_path)
              cur = conn.cursor()
              cur.execute("""
                  SELECT
                      datetime(history.start_time, "unixepoch", "localtime"),
                      history.duration,
                      history.exit_status,
                      places.dir
                  FROM history
                  JOIN commands ON history.command_id = commands.id
                  JOIN places ON history.place_id = places.id
                  WHERE commands.argv = ?
                  ORDER BY history.start_time DESC
                  LIMIT 5
              """, (cmd,))
              rows = cur.fetchall()
              for row in rows:
                  time_str, dur, status, d = row
                  status_str = "ok" if status == 0 else f"err {status}" if status is not None else "?"
                  dur_str = f"{dur}s" if dur is not None else "0s"
                  print(f"│ • {time_str} ({status_str}, {dur_str}) in {d}")
              conn.close()
          except Exception:
              pass
          ' "$db" "$cmd"
                    fi
                    echo -e "├── Actions ───────────────────────────────────────"
                    echo -e "│ • Enter:  Execute command"
                    echo -e "│ • Ctrl-y: Copy command to clipboard"
                    echo -e "│ • Ctrl-d: Delete entry from history database"
                    echo -e "╰──────────────────────────────────────────────────"
        '';
        tv-histdb-source = pkgs.writeShellScript "tv-histdb-source" ''
          db="''${HISTDB_FILE:-$HOME/.local/share/zsh/history.db}"
          if [ -f "$db" ]; then
            ${pkgs.sqlite}/bin/sqlite3 -batch -noheader -separator $'\t' "$db" "
              SELECT
                replace(replace(commands.argv, char(10), ' '), char(13), ' '),
                datetime(max(history.start_time), 'unixepoch', 'localtime'),
                places.dir
              FROM history
              JOIN commands ON history.command_id = commands.id
              JOIN places ON history.place_id = places.id
              GROUP BY commands.argv
              ORDER BY max(history.start_time) DESC;
            " 2>/dev/null
          elif [ -f "''${HISTFILE:-$HOME/.zsh_history}" ]; then
            ${pkgs.gnused}/bin/sed '1!G;h;$!d' "''${HISTFILE:-$HOME/.zsh_history}" | ${pkgs.gawk}/bin/awk -F';' '{cmd=$0; sub(/^:[^;]*;/, "", cmd); print cmd "\t-\t~"}'
          fi
        '';
        tv-history-delete = pkgs.writeShellScriptBin "tv-history-delete" ''
                    target="$1"
                    if [ -z "$target" ]; then
                      echo "No target command provided." >&2
                      exit 1
                    fi

                    db="''${HISTDB_FILE:-$HOME/.local/share/zsh/history.db}"
                    deleted=0

                    if [ -f "$db" ]; then
                      if ${pkgs.python3}/bin/python3 -c '
          import sys, sqlite3
          db_path, cmd = sys.argv[1], sys.argv[2]
          try:
              conn = sqlite3.connect(db_path)
              cur = conn.cursor()
              cur.execute("DELETE FROM history WHERE command_id IN (SELECT id FROM commands WHERE argv = ?)", (cmd,))
              cur.execute("DELETE FROM commands WHERE argv = ?", (cmd,))
              conn.commit()
              conn.close()
          except Exception:
              sys.exit(1)
          ' "$db" "$target"; then
                        deleted=1
                      fi
                    fi

                    histfile="''${HISTFILE:-$HOME/.zsh_history}"
                    if [ -f "$histfile" ]; then
                      tmp_file=$(mktemp "$histfile.tmp.XXXXXX")
                      ${pkgs.gawk}/bin/awk -v exact="$target" '
                        $0 == exact { next }
                        {
                          raw = $0
                          stripped = raw
                          if (sub(/^:[ \t]*[0-9]+:[0-9]+;/, "", stripped) && stripped == exact) next
                          print raw
                        }
                      ' "$histfile" > "$tmp_file" && mv "$tmp_file" "$histfile" && deleted=1
                    fi

                    if [ "$deleted" -eq 1 ]; then
                      echo "Deleted from history: $target"
                    else
                      echo "History entry not found: $target" >&2
                      exit 1
                    fi
        '';
        tv-hypr-client-preview = pkgs.writeShellScript "tv-hypr-client-preview" ''
          addr="$1"
          ${pkgs.hyprland or "hyprctl"}/bin/hyprctl clients -j 2>/dev/null | ${pkgs.jq}/bin/jq -r --arg addr "$addr" '
            .[] | select(.address == $addr) |
            "╭── Window: \(.title) ───\n" +
            "│ Class:       \(.class) (\(.initialClass))\n" +
            "│ Workspace:   \(.workspace.name) (id: \(.workspace.id))\n" +
            "│ Monitor:     \(.monitor)\n" +
            "│ Address:     \(.address)\n" +
            "│ PID:         \(.pid)\n" +
            "│ Floating:    \(.floating)\n" +
            "│ Fullscreen:  \(.fullscreen)\n" +
            "│ Size:        \(.size[0])x\(.size[1])\n" +
            "│ Position:    \(.at[0]),\(.at[1])\n" +
            "╰────────────────────────────────────────"
          '
        '';
        tv-hypr-workspace-preview = pkgs.writeShellScript "tv-hypr-workspace-preview" ''
          ws_id="$1"
          ${pkgs.hyprland or "hyprctl"}/bin/hyprctl clients -j 2>/dev/null | ${pkgs.jq}/bin/jq -r --arg id "$ws_id" '
            [ .[] | select((.workspace.id|tostring) == $id) ] as $clients |
            "╭── Workspace ID: " + $id + " (" + ($clients[0].workspace.name // "") + ") ───\n" +
            "│ Windows: " + ($clients | length | tostring) + "\n" +
            "├── Clients ─────────────────────────────\n" +
            (if ($clients | length) == 0 then "│ (No windows)\n" else
              ($clients | map("│ • [" + .class + "] " + .title) | join("\n")) + "\n"
            end) +
            "╰────────────────────────────────────────"
          '
        '';
        tv-media-player-preview = pkgs.writeShellScript "tv-media-player-preview" ''
          p="$1"
          echo -e "╭── Media Player: $p ────────────────────────"
          echo -e "│ Status:   $(playerctl -p "$p" status 2>/dev/null)"
          echo -e "│ Title:    $(playerctl -p "$p" metadata title 2>/dev/null)"
          echo -e "│ Artist:   $(playerctl -p "$p" metadata artist 2>/dev/null)"
          echo -e "│ Album:    $(playerctl -p "$p" metadata album 2>/dev/null)"
          echo -e "│ Position: $(playerctl -p "$p" position 2>/dev/null)s"
          echo -e "╰────────────────────────────────────────────"
        '';
      in
      {
        home.packages =
          with pkgs;
          [
            nix-search-tv
            tv-history-delete
          ]
          ++ (lib.optionals (pkgs ? local) (
            with pkgs.local;
            [
              rebuild-switch
              nix-generations
            ]
          ));

        programs.television = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };

        systemd.user.services.update-cli-caches = {
          Service = {
            ExecStart = [
              "${pkgs.tealdeer}/bin/tldr --update"
              "${pkgs.television}/bin/tv update-channels"
            ];

            Type = "oneshot";
          };

          Unit.Description = "Update tldr pages and television channels";
        };

        systemd.user.timers.update-cli-caches = {
          Install.WantedBy = [ "timers.target" ];

          Timer = {
            OnCalendar = "weekly";
            Persistent = true;
            RandomizedDelaySec = "1h";
          };

          Unit.Description = "Weekly tldr/television cache update";
        };

        # Television channel switcher cable with dynamic $TV_CMD propagation
        xdg.configFile."television/cable/channels.toml".text =
          # toml
          ''
            [metadata]
            name = "channels"
            description = "Select a television channel"
            requirements = ["tv", "bat"]

            [source]
            command = ["tv list-channels"]

            [preview]
            command = "bat -pn --color always ''${TELEVISION_CONFIG:-''${XDG_CONFIG_HOME:-$HOME/.config}/television}/cable/{}.toml"
            shell = "bash"

            [keybindings]
            enter = "actions:channel-enter"

            [actions.channel-enter]
            description = "Enter a television channel"
            command = "${tv-channel-enter} '{}'"
            mode = "execute"
          '';

        xdg.configFile."television/cable/flake-inputs.toml".text =
          # toml
          ''
            [metadata]
            name = "flake-inputs"
            description = "Interactively select and update Nix flake inputs"
            requirements = ["nix", "jq"]

            [source]
            command = "nix flake metadata --json 2>/dev/null | jq -r '.locks.nodes.root.inputs | keys[]'"

            [preview]
            command = "nix flake metadata --json 2>/dev/null | jq --arg k '{}' '.locks.nodes[$k] // .locks.nodes.root.inputs[$k]'"

            [keybindings]
            enter = "actions:update"
            ctrl-y = "actions:copy"

            [actions.update]
            description = "Update selected flake input"
            command = "nix flake update {}"
            mode = "execute"

            [actions.copy]
            description = "Copy input name to clipboard"
            command = "echo -n '{}' | wl-copy"
            mode = "execute"
          '';

        # Hyprland clients
        xdg.configFile."television/cable/hypr-clients.toml".text =
          # toml
          ''
            [metadata]
            name = "hypr-clients"
            description = "Fuzzy search and manage Hyprland windows"
            requirements = ["hyprctl", "jq"]

            [source]
            command = "hyprctl clients -j 2>/dev/null | jq -r '.[] | [(.workspace.name // (.workspace.id|tostring)), .class, .title, .address] | @tsv'"
            display = "[{split:\t:0}] {split:\t:1}  │  {split:\t:2}"
            output = "{split:\t:3}"

            [preview]
            command = "${tv-hypr-client-preview} '{}'"

            [keybindings]
            enter = "actions:focus"
            ctrl-d = "actions:close_window"
            ctrl-f = "actions:toggle_floating"
            ctrl-m = "actions:fullscreen"
            ctrl-y = "actions:copy_title"
            [actions.focus]
            description = "Focus the selected window"
            command = "hyprctl dispatch focuswindow address:{}"
            mode = "execute"

            [actions.close_window]
            description = "Close the selected window"
            command = "hyprctl dispatch closewindow address:{}"
            mode = "execute"

            [actions.toggle_floating]
            description = "Toggle floating mode for window"
            command = "hyprctl dispatch togglefloating address:{}"
            mode = "execute"

            [actions.fullscreen]
            description = "Toggle fullscreen for window"
            command = "hyprctl dispatch fullscreen 1 address:{}"
            mode = "execute"

            [actions.copy_title]
            description = "Copy window title to clipboard"
            command = "hyprctl clients -j 2>/dev/null | jq -r --arg addr '{}' '.[] | select(.address == $addr) | .title' | wl-copy"
            mode = "execute"

            [actions.print_json]
            description = "Print selected client JSON to stdout"
            command = "hyprctl clients -j 2>/dev/null | jq --arg addr '{}' '.[] | select(.address == $addr)'"
            mode = "execute"
          '';

        # Hyprland workspaces
        xdg.configFile."television/cable/hypr-workspaces.toml".text =
          # toml
          ''
            [metadata]
            name = "hypr-workspaces"
            description = "Fuzzy search and switch Hyprland workspaces"
            requirements = ["hyprctl", "jq"]

            [source]
            command = "hyprctl workspaces -j 2>/dev/null | jq -r '.[] | [(.id|tostring), .name, .monitor, (.windows|tostring), (.lastwindowtitle // \"None\")] | @tsv'"
            display = "[WS {split:\t:0}: {split:\t:1}]  │  Monitor: {split:\t:2}  │  Windows: {split:\t:3}  │  {split:\t:4}"
            output = "{split:\t:0}"

            [preview]
            command = "${tv-hypr-workspace-preview} '{}'"

            [keybindings]
            enter = "actions:switch"
            ctrl-y = "actions:copy_id"

            [actions.switch]
            description = "Switch to this workspace"
            command = "hyprctl dispatch workspace {}"
            mode = "execute"

            [actions.copy_id]
            description = "Copy workspace ID to clipboard"
            command = "echo -n '{}' | wl-copy"
            mode = "execute"
          '';

        xdg.configFile."television/cable/mdless.toml".text =
          # toml
          ''
            [metadata]
            name = "mdless"
            description = "Browse and page markdown files using mdless"
            requirements = ["mdcat", "fd"]

            [source]
            command = "fd --type f -e md -e markdown -e mdx -e mdown"

            [preview]
            command = "${pkgs.mdcat}/bin/mdcat --columns $COLUMNS '{}'"

            [keybindings]
            enter = "actions:page"
            ctrl-e = "actions:edit"
            ctrl-y = "actions:copy"

            [actions.page]
            description = "Page markdown file with mdless"
            command = "${pkgs.mdcat}/bin/mdless '{}'"
            mode = "execute"

            [actions.edit]
            description = "Edit markdown file in $EDITOR"
            command = "''${EDITOR:-nvim} '{}'"
            mode = "execute"

            [actions.copy]
            description = "Copy file path to clipboard"
            command = "echo -n '{}' | wl-copy"
            mode = "execute"
          '';

        # Markdown picker channels using mdcat / mdless
        xdg.configFile."television/cable/mdpick.toml".text =
          # toml
          ''
            [metadata]
            name = "mdpick"
            description = "Fuzzy search and preview markdown files with mdcat"
            requirements = ["mdcat", "fd"]

            [source]
            command = "fd --type f -e md -e markdown -e mdx -e mdown"

            [preview]
            command = "${pkgs.mdcat}/bin/mdcat --columns $COLUMNS '{}'"

            [keybindings]
            enter = "actions:view"
            ctrl-e = "actions:edit"
            ctrl-y = "actions:copy"

            [actions.view]
            description = "View markdown with mdless"
            command = "${pkgs.mdcat}/bin/mdless '{}'"
            mode = "execute"

            [actions.edit]
            description = "Edit markdown file in $EDITOR"
            command = "''${EDITOR:-nvim} '{}'"
            mode = "execute"

            [actions.copy]
            description = "Copy file path to clipboard"
            command = "echo -n '{}' | wl-copy"
            mode = "execute"
          '';

        # Media player controls
        xdg.configFile."television/cable/media-players.toml".text =
          # toml
          ''
            [metadata]
            name = "media-players"
            description = "Inspect and control MPRIS media players via playerctl"
            requirements = ["playerctl"]

            [source]
            command = "playerctl -a metadata --format '{{playerName}}\t{{status}}\t{{title}}\t{{artist}}' 2>/dev/null"
            display = "[{split:\t:0}] {split:\t:1}  │  {split:\t:2}  -  {split:\t:3}"
            output = "{split:\t:0}"

            [preview]
            command = "${tv-media-player-preview} '{}'"

            [keybindings]
            enter = "actions:play_pause"
            ctrl-q = "actions:next"
            ctrl-b = "actions:previous"
            ctrl-d = "actions:stop"
            [actions.play_pause]
            description = "Play / Pause playback"
            command = "playerctl -p '{}' play-pause"
            mode = "execute"

            [actions.next]
            description = "Skip to next track"
            command = "playerctl -p '{}' next"
            mode = "execute"

            [actions.previous]
            description = "Return to previous track"
            command = "playerctl -p '{}' previous"
            mode = "execute"

            [actions.stop]
            description = "Stop playback"
            command = "playerctl -p '{}' stop"
            mode = "execute"
          '';

        # NixOS system generations management cable
        xdg.configFile."television/cable/nix-generations.toml".text =
          let
            nixGenBin =
              if pkgs ? local && pkgs.local ? nix-generations then
                "${pkgs.local.nix-generations}/bin/nix-generations"
              else
                "nix-generations";
          in
          # toml
          ''
            [metadata]
            name = "nix-generations"
            description = "Fuzzy search, preview, switch, and delete NixOS system generations"
            requirements = ["nix-generations"]

            [source]
            command = "${nixGenBin} list"
            display = "[{split:\t:0}] {split:\t:1} {split:\t:2}  │  {split:\t:3}"
            output = "{split:\t:0}"
            no_sort = true
            frecency = false

            [preview]
            command = "${nixGenBin} preview '{split:\t:0}'"

            [keybindings]
            enter = "actions:switch"
            ctrl-b = "actions:boot"
            ctrl-d = "actions:delete"
            ctrl-o = "actions:delete-older"
            ctrl-y = "actions:copy"

            [actions.switch]
            description = "Switch active system to selected generation"
            command = "${nixGenBin} switch '{split:\t:0}'"
            mode = "execute"

            [actions.boot]
            description = "Set selected generation as boot default"
            command = "${nixGenBin} boot '{split:\t:0}'"
            mode = "execute"

            [actions.delete]
            description = "Delete selected generation"
            command = "${nixGenBin} delete '{split:\t:0}'"
            mode = "execute"

            [actions.delete-older]
            description = "Delete older generations (clean with keep count or older than selected)"
            command = "${nixGenBin} delete-older '{split:\t:0}'"
            mode = "execute"

            [actions.copy]
            description = "Copy store path to clipboard"
            command = "echo -n '{split:\t:4}' | wl-copy"
            mode = "execute"
          '';

        # Nix options only
        xdg.configFile."television/cable/nix-options.toml".text =
          # toml
          ''
            [metadata]
            name = "nix-options"
            description = "Fuzzy search NixOS and Home Manager options via nix-search-tv"
            requirements = ["nix-search-tv", "grep"]

            [source]
            command = "${pkgs.nix-search-tv}/bin/nix-search-tv print | ${pkgs.gnugrep}/bin/grep -E '^(nixos/|home-manager/)'"
            display = "{split:/ :0}  │  {split:/ :1}"
            output = "{split:/ :1}"

            [preview]
            command = "${pkgs.nix-search-tv}/bin/nix-search-tv preview '{}'"

            [keybindings]
            enter = "actions:copy"
            ctrl-y = "actions:copy"
            ctrl-s = "actions:source"

            [actions.copy]
            description = "Copy option name to clipboard"
            command = "echo -n '{split:/ :1}' | wl-copy"
            mode = "execute"

            [actions.source]
            description = "Open option declaration in browser"
            command = "url=$(${pkgs.nix-search-tv}/bin/nix-search-tv source '{}') && [ -n \"$url\" ] && xdg-open \"$url\""
            mode = "fork"
          '';

        # Nix packages only
        xdg.configFile."television/cable/nix-pkgs.toml".text =
          # toml
          ''
            [metadata]
            name = "nix-pkgs"
            description = "Fuzzy search Nixpkgs packages via nix-search-tv"
            requirements = ["nix-search-tv", "grep"]

            [source]
            command = "${pkgs.nix-search-tv}/bin/nix-search-tv print | ${pkgs.gnugrep}/bin/grep '^nixpkgs/'"
            display = "{split:/ :1}"
            output = "{split:/ :1}"

            [preview]
            command = "${pkgs.nix-search-tv}/bin/nix-search-tv preview '{}'"

            [keybindings]
            enter = "actions:copy"
            ctrl-y = "actions:copy"
            ctrl-s = "actions:source"
            ctrl-h = "actions:homepage"

            [actions.copy]
            description = "Copy package name to clipboard"
            command = "echo -n '{split:/ :1}' | wl-copy"
            mode = "execute"

            [actions.source]
            description = "Open source declaration in browser"
            command = "url=$(${pkgs.nix-search-tv}/bin/nix-search-tv source '{}') && [ -n \"$url\" ] && xdg-open \"$url\""
            mode = "fork"

            [actions.homepage]
            description = "Open package homepage in browser"
            command = "url=$(${pkgs.nix-search-tv}/bin/nix-search-tv homepage '{}') && [ -n \"$url\" ] && xdg-open \"$url\""
            mode = "fork"
          '';

        # Unified Nix search
        xdg.configFile."television/cable/nix.toml".text =
          # toml
          ''
            [metadata]
            name = "nix"
            description = "Fuzzy search Nixpkgs packages, NixOS options, and Home Manager options"
            requirements = ["nix-search-tv"]

            [source]
            command = "${pkgs.nix-search-tv}/bin/nix-search-tv print"
            display = "{split:/ :0}  │  {split:/ :1}"
            output = "{split:/ :1}"

            [preview]
            command = "${pkgs.nix-search-tv}/bin/nix-search-tv preview '{}'"

            [keybindings]
            enter = "actions:copy"
            ctrl-y = "actions:copy"
            ctrl-s = "actions:source"
            ctrl-h = "actions:homepage"

            [actions.copy]
            description = "Copy package/option name to clipboard"
            command = "echo -n '{split:/ :1}' | wl-copy"
            mode = "execute"

            [actions.source]
            description = "Open source declaration in browser"
            command = "url=$(${pkgs.nix-search-tv}/bin/nix-search-tv source '{}') && [ -n \"$url\" ] && xdg-open \"$url\""
            mode = "fork"

            [actions.homepage]
            description = "Open homepage in browser"
            command = "url=$(${pkgs.nix-search-tv}/bin/nix-search-tv homepage '{}') && [ -n \"$url\" ] && xdg-open \"$url\""
            mode = "fork"
          '';

        # Enhanced zsh history backed by zsh-histdb SQLite
        xdg.configFile."television/cable/zsh-history.toml".text =
          # toml
          ''
            [metadata]
            name = "zsh-history"
            description = "Fuzzy search, execute, and manage shell command history from zsh-histdb"
            requirements = ["sqlite3", "zsh"]

            [source]
            command = "${tv-histdb-source}"
            display = "[{split:\t:1}]  {split:\t:0}  │  {split:\t:2}"
            output = "{split:\t:0}"
            no_sort = true
            frecency = false

            [preview]
            command = "${tv-histdb-preview} '{split:\t:0}' '{split:\t:1}' '{split:\t:2}'"

            [keybindings]
            enter = "actions:execute"
            ctrl-y = "actions:copy"
            ctrl-d = "actions:delete"

            [actions.execute]
            description = "Execute the selected command"
            command = "zsh -c '{split:\t:0}'"
            mode = "execute"

            [actions.copy]
            description = "Copy command to clipboard"
            command = "echo -n '{split:\t:0}' | wl-copy"
            mode = "execute"

            [actions.delete]
            description = "Delete this command entry from zsh-histdb"
            command = "${tv-history-delete}/bin/tv-history-delete '{split:\t:0}'"
            mode = "execute"
          '';

        xdg.configFile."television/config.toml".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/television/config.toml";

        xdg.configFile."television/themes/catppuccin-mocha-mauve.toml".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/television/themes/catppuccin-mocha-mauve.toml";

        xdg.configFile."television/tv-slim.toml".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/television/tv-slim.toml";
      };

    persistHome.directories = [
      ".local/share/television"
    ];
  };
}
