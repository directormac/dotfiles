{
  inputs,
  self,
  ...
}:
{
  flake.homeModules.television =
    { pkgs, config, ... }:
    let
      # History deletion script for zsh-history cable
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
    in
    {
      home.packages = with pkgs; [
        nix-search-tv
        tv-history-delete
      ];

      programs.television = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
      };

      # Television config link
      xdg.configFile."television/config.toml".source =
        config.lib.file.mkOutOfStoreSymlink ../../../config/television/config.toml;

      xdg.configFile."television/tv-slim.toml".source =
        config.lib.file.mkOutOfStoreSymlink ../../../config/television/tv-slim.toml;

      xdg.configFile."television/themes/catppuccin-mocha-mauve.toml".source =
        config.lib.file.mkOutOfStoreSymlink ../../../config/television/themes/catppuccin-mocha-mauve.toml;

      xdg.configFile."television/cable/flake-inputs".text =
        # toml
        ''
          [metadata]
          name = "flake-inputs"
          description = "Interactively select and update Nix flake inputs"

          [source]
          command = "nix flake metadata --json | jq -r '.locks.nodes.root.inputs | keys[]'"

          [keybindings]
          enter = "actions:update"

          [actions.update]
          command = "nix flake update {}"
          mode = "execute"
        '';

      # Cable: Unified Nix Search (packages, NixOS options, Home Manager options via nix-search-tv)
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

      # Cable: Nix Packages only
      xdg.configFile."television/cable/nix-packages.toml".text =
        # toml
        ''
          [metadata]
          name = "nix-packages"
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

      # Cable: Nix Options only (NixOS & Home Manager)
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

      # Cable: Enhanced Zsh History with Delete capability
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

      # Cable: Hyprland Clients
      xdg.configFile."television/cable/hypr-clients.toml".text =
        # toml
        ''
          [metadata]
          name = "hypr-clients"
          description = "Fuzzy search Hyprland windows with JSON preview"
          requirements = ["hyprctl", "jq"]

          [source]
          command = "hyprctl clients -j | jq -r '.[] | [.workspace.id, .class, .title, .address] | @tsv'"
          display = "{split:\t:0}  │  {split:\t:1}"
          output = "{split:\t:3}"

          [preview]
          command = "hyprctl clients -j | jq -r --arg addr '{}' '.[] | select(.address == $addr) | \"Class: \" + .class, \"Initial Class: \" + .initialClass, \"Title: \" + .title, \"Initial Title: \" + .initialTitle, \"Workspace: \" + (.workspace.id | tostring) + \" (\" + .workspace.name + \")\", \"PID: \" + (.pid | tostring), \"Floating: \" + (.floating | tostring), \"Monitor: \" + (.monitor | tostring), \"Size: \" + (.size[0] | tostring) + \"x\" + (.size[1] | tostring), \"At: \" + (.at[0] | tostring) + \", \" + (.at[1] | tostring), \"Address: \" + .address'"

          [keybindings]
          enter = "actions:print_json"
          ctrl-f = "actions:focus"

          [actions.print_json]
          description = "Print selected client JSON to stdout"
          command = "hyprctl clients -j | jq --arg addr '{}' '.[] | select(.address == $addr)'"
          mode = "execute"

          [actions.focus]
          description = "Focus the selected window"
          command = "hyprctl dispatch focuswindow address:{}"
          mode = "execute"
        '';
    };

  flake.nixosModules.television =
    { pkgs, config, ... }:
    {
      home-manager.users.${config.preferences.user.name} = {
        imports = [
          self.homeModules.television
        ];
      };

      environment.systemPackages = with pkgs; [
        television
        nix-search-tv
        jq
      ];
    };
}
