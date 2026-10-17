# Television Fuzzy Finder Aspect with Custom Cables and Cache Update Timer
{
  den.aspects.applications.dev.shell.television = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          television
          nix-search-tv
          jq
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

        tv-history-delete = pkgs.writeShellScriptBin "tv-history-delete" ''
          target="$1"
          histfile="''${HISTFILE:-$HOME/.zsh_history}"
          if [ -z "$target" ] || [ ! -f "$histfile" ]; then
            echo "No target or history file found." >&2
            exit 1
          fi
          tmp_file=$(mktemp "$histfile.tmp.XXXXXX")
          if ${pkgs.gnugrep}/bin/grep -Fxv "$target" "$histfile" > "$tmp_file"; then
            mv "$tmp_file" "$histfile"
            echo "Deleted from history: $target"
          else
            rm -f "$tmp_file"
            echo "Entry not found in history." >&2
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
        home.packages = with pkgs; [
          nix-search-tv
          tv-history-delete
        ];

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
            ctrl-x = "actions:close_window"
            ctrl-d = "actions:close_window"
            ctrl-f = "actions:toggle_floating"
            ctrl-m = "actions:fullscreen"
            ctrl-y = "actions:copy_title"
            ctrl-p = "actions:print_json"

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
            ctrl-n = "actions:next"
            ctrl-p = "actions:previous"
            ctrl-s = "actions:stop"

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

        # Enhanced zsh history with deletion
        xdg.configFile."television/cable/zsh-history.toml".text =
          # toml
          ''
            [metadata]
            name = "zsh-history"
            description = "Search shell history with options to execute or delete"
            requirements = ["zsh", "sed", "grep"]

            [source]
            command = "${pkgs.gnused}/bin/sed '1!G;h;$!d' ''${HISTFILE:-''${HOME}/.zsh_history}"
            display = "{split:;:1..}"
            output = "{split:;:1..}"
            no_sort = true
            frecency = false

            [preview]
            command = "echo -e '╭── History Entry ─────────────────────\n│ Command: {split:;:1..}\n│ Raw:     {}\n╰──────────────────────────────────────'"

            [keybindings]
            enter = "actions:execute"
            ctrl-y = "actions:copy"
            ctrl-d = "actions:delete"

            [actions.execute]
            description = "Execute the selected command"
            command = "zsh -c '{split:;:1..}'"
            mode = "execute"

            [actions.copy]
            description = "Copy command to clipboard"
            command = "echo -n '{split:;:1..}' | wl-copy"
            mode = "execute"

            [actions.delete]
            description = "Delete this entry from ~/.zsh_history"
            command = "${tv-history-delete}/bin/tv-history-delete '{}'"
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
