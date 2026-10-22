# Television Fuzzy Finder Aspect with Custom Cables and Cache Update Timer
# https://github.com/alexpasmantier/television
# https://alexpasmantier.github.io/television/
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
        ...
      }:
      let
        tv-channel-enter = pkgs.writeShellScriptBin "tv-channel-enter" ''
          chan="$1"
          if [ -n "''${TV_CMD:-}" ]; then
            cmd_args="''${TV_CMD#tv }"
            exec ${pkgs.television}/bin/tv $cmd_args "$chan"
          else
            exec ${pkgs.television}/bin/tv "$chan"
          fi
        '';
        tv-histdb-preview = pkgs.writeShellScriptBin "tv-histdb-preview" ''
          cmd="$1"
          last_run="$2"
          last_dir="$3"
          db="''${HISTDB_FILE:-$HOME/.local/share/zsh/history.db}"

          echo "$cmd"
          if [ -n "$last_run" ] && [ "$last_run" != "-" ]; then
            echo "last run: $last_run in $last_dir"
          fi

          if [ -f "$db" ] && [ -n "$cmd" ]; then
            echo ""
            echo "recent runs"
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
                  print(f"  {time_str} ({status_str}, {dur_str}) in {d}")
              conn.close()
          except Exception:
              pass
          ' "$db" "$cmd"
          fi
        '';
        tv-histdb-source = pkgs.writeShellScriptBin "tv-histdb-source" ''
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
        tv-hypr-client-preview = pkgs.writeShellScriptBin "tv-hypr-client-preview" ''
          addr="$1"
          ${pkgs.hyprland or "hyprctl"}/bin/hyprctl clients -j 2>/dev/null | ${pkgs.jq}/bin/jq -r --arg addr "$addr" '
            .[] | select(.address == $addr) |
            "\(.title)\n" +
            "class: \(.class) (\(.initialClass))\n" +
            "workspace: \(.workspace.name) (id: \(.workspace.id))\n" +
            "monitor: \(.monitor)\n" +
            "address: \(.address)\n" +
            "pid: \(.pid)\n" +
            "floating: \(.floating) | fullscreen: \(.fullscreen)\n" +
            "size: \(.size[0])x\(.size[1]) at \(.at[0]),\(.at[1])"
          '
        '';
        tv-hypr-workspace-preview = pkgs.writeShellScriptBin "tv-hypr-workspace-preview" ''
          ws_id="$1"
          ${pkgs.hyprland or "hyprctl"}/bin/hyprctl clients -j 2>/dev/null | ${pkgs.jq}/bin/jq -r --arg id "$ws_id" '
            [ .[] | select((.workspace.id|tostring) == $id) ] as $clients |
            "workspace " + $id + " (" + ($clients[0].workspace.name // "") + ")\n" +
            "windows: " + ($clients | length | tostring) + "\n\n" +
            "clients\n" +
            (if ($clients | length) == 0 then "  (no windows)\n" else
              ($clients | map("  [" + .class + "] " + .title) | join("\n")) + "\n"
            end)
          '
        '';
        tv-media-player-preview = pkgs.writeShellScriptBin "tv-media-player-preview" ''
          p="$1"
          echo "player: $p"
          echo "status: $(${pkgs.playerctl}/bin/playerctl -p "$p" status 2>/dev/null)"
          echo "title:  $(${pkgs.playerctl}/bin/playerctl -p "$p" metadata title 2>/dev/null)"
          echo "artist: $(${pkgs.playerctl}/bin/playerctl -p "$p" metadata artist 2>/dev/null)"
          echo "album:  $(${pkgs.playerctl}/bin/playerctl -p "$p" metadata album 2>/dev/null)"
          pos=$(${pkgs.playerctl}/bin/playerctl -p "$p" position 2>/dev/null)
          [ -n "$pos" ] && echo "position: ''${pos}s"
        '';
      in
      {
        home.packages =
          with pkgs;
          [
            nix-search-tv
            tv-channel-enter
            tv-histdb-preview
            tv-histdb-source
            tv-history-delete
            tv-hypr-client-preview
            tv-hypr-workspace-preview
            tv-media-player-preview
          ]
          ++ (lib.optionals (pkgs ? local) (
            with pkgs.local;
            [
              rebuild-switch
              nix-generations
            ]
          ));

        programs.nix-search-tv = {
          enable = true;
          enableTelevisionIntegration = true;
        };

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

        xdg.configFile =
          builtins.listToAttrs (
            map
              (name: {
                name = "television/cable/${name}";
                value.source = config.lib.dots.link "television/cable/${name}";
              })
              [
                "channels.toml"
                "flake-inputs.toml"
                "hypr-clients.toml"
                "hypr-workspaces.toml"
                "mdless.toml"
                "mdpick.toml"
                "media-players.toml"
                "nix-generations.toml"
                "nix-options.toml"
                "nix-pkgs.toml"
                "nix.toml"
                "zsh-history.toml"
              ]
          )
          // {
            "television/config.toml".source = config.lib.dots.link "television/config.toml";

            "television/themes/catppuccin-mocha-mauve.toml".source =
              config.lib.dots.link "television/themes/catppuccin-mocha-mauve.toml";

            "television/tv-slim.toml".source = config.lib.dots.link "television/tv-slim.toml";
          };
      };

    persistHome.directories = [
      ".local/share/television"
    ];
  };
}
