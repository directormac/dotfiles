{
  inputs,
  self,
  ...
}:
{
  flake.homeModules.tmux =
    { pkgs, config, ... }:
    let
      tmuxPkg = self.packages.${pkgs.stdenv.hostPlatform.system}.tmux;

      kanjiIndex = "#{?#{==:#I,1},一,#{==:#I,2},二,#{==:#I,3},三,#{==:#I,4},四,#{==:#I,5},五,#{==:#I,6},六,#{==:#I,7},七,#{==:#I,8},八,#{==:#I,9},九,#{==:#I,10},十,#I}";
      windowIcon = "#{?#{&&:#{!=:#{@workmux_status},},#{||:#{m:*●*,#W},#{m:**,#W},#{m:*󰚩*,#W},#{m:*󱙺*,#W}}},#{@workmux_status},#W#{?@workmux_status, #{@workmux_status},}}";

      tmux-fzf-links = pkgs.tmuxPlugins.mkTmuxPlugin {
        pluginName = "tmux-fzf-links";
        version = "1.5.1";
        # Upstream entrypoint is fzf-links.tmux
        rtpFilePath = "fzf-links.tmux";
        src = pkgs.fetchFromGitHub {
          owner = "alberti42";
          repo = "tmux-fzf-links";
          tag = "1.5.1";
          sha256 = "1jb9zvnzn494m03b6kizazpibdhqvfjywy9shs1p838jafbn6f5c";
        };
      };

      # devel branch - main does not support tmux 3.8+
      tmux-menus = pkgs.tmuxPlugins.mkTmuxPlugin {
        pluginName = "tmux-menus";
        version = "0-unstable-2026-10-02";
        rtpFilePath = "menus.tmux";
        src = pkgs.fetchFromGitHub {
          owner = "jaclu";
          repo = "tmux-menus";
          rev = "30a18ec5e949db228f1596937880e494a7be49ef";
          hash = "sha256-C2rFzuR12ap2ytX03XaBycNia3vzaexFdOFM3qrSsUw=";
        };
      };

    in
    {
      xdg = {
        configFile = {
          # Configuration for tmux-nerd-font-window-name: icon-only window display
          "tmux/tmux-nerd-font-window-name.yml".source =
            config.lib.file.mkOutOfStoreSymlink ../../../config/tmux/tmux-nerd-font-window-name.yml;

          "tmux/status.tmux.conf".source =
            config.lib.file.mkOutOfStoreSymlink ../../../config/tmux/status.tmux.conf;

          "tmux/scripts" = {
            source = config.lib.file.mkOutOfStoreSymlink ../../../config/tmux/scripts;
            force = true;
          };
        };
      };

      # FAQ https://github.com/tmux/tmux/wiki/FAQ
      programs.tmux = {
        enable = true;
        package = tmuxPkg;
        prefix = "C-a";
        shortcut = "a";
        clock24 = true;
        baseIndex = 1;
        keyMode = "vi";
        # newSession = true;
        focusEvents = true;
        aggressiveResize = true;
        mouse = true;
        escapeTime = 100;
        historyLimit = 1000000;
        customPaneNavigationAndResize = true;
        terminal = "tmux-256color";

        # Pieces of config from our config/tmux.conf
        # References
        # https://github.com/catppuccin/tmux/discussions/317#discussioncomment-12731361
        extraConfig =
          # sh
          ''
            # General Settings
            set -g status-interval 1
            set -g history-limit 100000
            set -g repeat-time 350
            set -g display-time 1500
            set -s set-clipboard on
            set -g renumber-windows on 
            set -g detach-on-destroy off
            set -g wrap-search off
            set -g allow-passthrough all
            set -g visual-activity off

            # Terminal 
            set -g default-terminal "tmux-256color"
            set -ga terminal-overrides ",*256col*:Tc"
            set -ga terminal-overrides ",xterm-ghostty:Tc"
            # Tell tmux that the *outside* terminal (Ghostty/Alacritty/etc.) supports True Color (RGB)
            # This works for Ghostty (which uses xterm-ghostty) and others using xterm-256color
            set -as terminal-features ",xterm-ghostty:RGB"
            set -as terminal-features ",xterm-256color:RGB"

            # https://github.com/tmux/tmux/wiki/Modifier-Keys#extended-keys
            set -s extended-keys on
            set -as terminal-features "xterm*:extkeys"

            # Bindings
            bind -N "Prompt a command" : command-prompt -P
            bind -N "Fuzzy search Tmux keybindings" ? display-popup -E -w 80% -h 75% -d "#{pane_current_path}" -T "Tmux Keybindings" "tmux list-keys -N -a | tv --config-file ~/.config/television/tv-slim.toml"
            bind -N "Television sesh" "t" display-popup -E -w 80% -h 70% -d '#{pane_current_path}' -T 'Sesh' "tv sesh --hide-preview --input-position bottom"
            bind -N "Jump to urgent window or toggle last window" ` if-shell -F "#{session_alerts}" "next-window -a" "last-window"
            bind -N "Reload Configuration" R source-file "~/.config/tmux/tmux.conf" \; display "Nix-managed tmux config reloaded!"
            bind -N "Copy selection" -T copy-mode-vi y send -X copy-pipe-and-cancel "wl-copy"
            bind -N "Create window" c new-window -c "#{pane_current_path}"
            bind -N "Create window cwd" C new-window
            bind -N "Display Clock" C-t clock-mode
            # bind -N "Kill pane" x confirm-before -p "Kill pane #P? (y/n)" kill-pane
            bind -N "Kill pane" x kill-pane
            bind -N "Kill window" q confirm-before -p "Kill window #W? (y/n)" kill-window
            bind -N "Kill session" X confirm-before -p "Kill session #S? (y/n)" kill-session
            bind -N "Split pane vertically" - split-window -v -c "#{pane_current_path}"
            bind -N "Split pane horizontally" \| split-window -h -c "#{pane_current_path}"
            # bind-key -N "Jump to urgent window or toggle last window" -n C-` if-shell -F "#{session_alerts}" "next-window -a" "last-window"

            bind -N "Begin selection" -T copy-mode-vi v send-keys -X begin-selection
            bind -N "Copy selection"  -T copy-mode-vi y send-keys -X copy-selection-and-cancel

            # Advanced Pane Movements & Inspection
            bind -N "Break pane to background window" B break-pane -d
            bind -N "Toggle marked pane" m select-pane -m
            bind -N "Join marked pane here" J join-pane
            bind -N "Inspect scrollback in Neovim" E display-popup -w 95% -h 90% -E "tmux capture-pane -p -S -3000 | nvim -c 'set buftype=nofile' -"
            bind -N "Respawn failed pane" r respawn-pane -k
            bind -N "Toggle synchronize panes" S set-window-option synchronize-panes

            # Unbind alt key, bound in neovim buffers.
            unbind-key -n M-0
            unbind-key -n M-1
            unbind-key -n M-2
            unbind-key -n M-3
            unbind-key -n M-4
            unbind-key -n M-5
            unbind-key -n M-6
            unbind-key -n M-7
            unbind-key -n M-8
            unbind-key -n M-9

            # bind -N "Go to left window" -n C-, select-window -t -1
            # bind -n "Go to right window" C-. select-window -t +1

            bind -N "Go to window 1" -T root C-1 select-window -t 1
            bind -N "Go to window 2" -T root C-2 select-window -t 2
            bind -N "Go to window 3" -T root C-3 select-window -t 3
            bind -N "Go to window 4" -T root C-4 select-window -t 4
            bind -N "Go to window 5" -T root C-5 select-window -t 5
            bind -N "Go to window 6" -T root C-6 select-window -t 6
            bind -N "Go to window 7" -T root C-7 select-window -t 7
            bind -N "Go to window 8" -T root C-8 select-window -t 8
            bind -N "Go to window 9" -T root C-9 select-window -t 9


            # Error Preservation & History
            set -g history-file "~/.local/state/tmux/tmux_history"
            set -g remain-on-exit 'failed'
            set-hook -gw pane-died 'display-message "⚠️ Pane #{hook_pane} exited with failure! Press any key to close, or Prefix + r to respawn."'
            set-hook -g session-window-changed 'run-shell -b "tmux set-option -q -u -w -t \"#{hook_old_window}\" synchronize-panes"'


            source -F "$HOME/.config/tmux/status.tmux.conf"
          '';

        # Plugins
        # https://github.com/tmux-plugins/list
        # https://search.nixos.org/packages?channel=unstable&query=tmuxPlugins.
        plugins = [
          # https://github.com/joshmedeski/tmux-nerd-font-window-name#nix-flakes
          # inputs.tmux-nerd-font-window-name.packages.${pkgs.stdenv.hostPlatform.system}.default
          {
            plugin = pkgs.tmuxPlugins.tmux-nerd-font-window-name;
            extraConfig =
              # sh
              ''
                set -g @tmux-nerd-font-window-name-config-file "$HOME/.config/tmux/tmux-nerd-font-window-name.yml"
                set -g automatic-rename-format "#{window_icon}"
              '';
          }
          # https://github.com/alberti42/tmux-fzf-links
          {
            plugin = tmux-fzf-links;
            extraConfig =
              # sh
              ''
                set -g @fzf-links-key "u"
                set -g @fzf-links-python "${pkgs.python3}/bin/python3"
                set -g @fzf-links-browser-open-cmd "zen-beta '%url'"
                set -g @fzf-links-editor-open-cmd "tmux new-window -n 'nvim' nvim +%line '%file'"
              '';
          }
          # https://github.com/jaclu/tmux-menus
          {
            plugin = tmux-menus;
            extraConfig =
              # sh
              ''
                # Tmux 3.8: Theme display-menu (tmux-menus plugin)
                # NOTE: menu-style lines moved to main extraConfig — they need @thm_*
                # which only exists after the catppuccin plugin runs.

                # Cache dir lives inside the plugin folder - read-only in the nix store
                set -g @menus_use_cache "No"
                # Explicit trigger key also disables the secondary <prefix> Enter default
                set -g @menus_trigger '\'
              '';
          }
        ]
        ++ (with pkgs.tmuxPlugins; [
          # catppuccin
          {
            plugin = catppuccin;
            extraConfig =
              # sh
              ''
                # Reference https://github.com/catppuccin/tmux/blob/main/docs/reference/configuration.md

                set -g @catppuccin_flavor "mocha" # latte,frappe, macchiato or mocha
                set -g @catppuccin_status_background "none" # none == default
                set -g @catppuccin_status_left_separator ""
                set -g @catppuccin_status_right_separator ""
                set -g @catppuccin_window_middle_separator ""

                # Panes Border
                set -g @catppuccin_pane_status_enabled "off"
                set -g @catppuccin_pane_border_status "off"
                set -g @catppuccin_pane_active_border_style "##{?pane_in_mode,fg=#{@thm_mauve},##{?pane_synchronized,fg=#{@thm_rosewater},fg=#{@thm_mauve}}}"
                set -g @catppuccin_pane_color "#{@thm_overlay_0}"

                set -g @catppuccin_window_status_style "custom"
                set -g @catppuccin_window_flags ""
                set -g @catppuccin_window_number ""

                # Window formatting:
                # 1. Shows window index (Kanji) only in prefix mode (#{?client_prefix,...})
                # 2. Replaces fallback (●, ) or agent (󰚩, 󱙺) icon with @workmux_status when active
                # 3. Keeps tool icons (e.g. nvim ) and appends @workmux_status
                # 4. Shows urgent icon () with maroon background on alert, moving bell out to status-right
                set -g @catppuccin_window_text "#{?window_bell_flag,#[fg=#{@thm_crust} bg=#{@thm_maroon} bold] #{?client_prefix,${kanjiIndex} ,} ${windowIcon} #[default],#[fg=#{@thm_mauve} bg=default] #{?client_prefix,${kanjiIndex} ,}${windowIcon} }"
                set -g @catppuccin_window_current_number ""
                set -g @catppuccin_window_current_text "#{?window_bell_flag,#[fg=#{@thm_crust} bg=#{@thm_maroon} bold]  ${windowIcon} #[default],#[fg=#{@thm_crust} bg=#{@thm_blue} bold] ${windowIcon} }"


                # Clean directory text: Strips conventional commit prefixes (e.g. feat/, fix-, refactor-)
                # set -g @catppuccin_directory_text "#(echo '#{b:pane_current_path}' | sed -E 's/^(feat|fix|refactor|docs|style|test|chore|ci|perf)([/-])//')"
                # set -g @catppuccin_session_text "#(echo '#S' | cut -d'-' -f1)"
              '';
          }
          {
            plugin = resurrect;
            extraConfig =
              # sh
              ''
                set -g @resurrect-strategy-vim "session"
                set -g @resurrect-strategy-nvim "session"
                # set -g @resurrect-capture-pane-contents "on"
                set -g @resurrect-processes "lazydocker lazygit yazi"
                resurrect_dir=$HOME/.local/state/tmux/resurrect/
                set -g @resurrect-dir $resurrect_dir
                set -g @resurrect-hook-post-save-all "sed -i 's| --cmd .*-vim-pack-dir||g; s|/etc/profiles/per-user/$USER/bin/||g; s|/nix/store/.*/bin/||g' $(readlink -f $resurrect_dir/last)"

                set -g @resurrect-save "C-S"
                set -g @resurrect-restore "C-R"
              '';
          }

          {
            plugin = continuum;
            extraConfig =
              # sh
              ''
                set -g @continuum-save-interval "5"
                set -g @continuum-restore "on"
              '';
          }

          # https://github.com/spywhere/tmux-named-snapshohttps://github.com/spywhere/tmux-named-snapshotqt
        ]);
      };

      systemd.user.services.tmux-server = {
        Unit = {
          Description = "tmux server (continuum auto-restore)";
          Documentation = "man:tmux(1)";
          # graphical-session.target is started by the display manager for any
          # session, so this stays independent of which compositor/WM is used.
          After = [ "graphical-session.target" ];
        };
        Service = {
          Type = "forking";
          Environment = [ "TMUX_TMPDIR=%t" ]; # %t = $XDG_RUNTIME_DIR -> matches your shell
          # systemd user units get no WAYLAND_DISPLAY/DISPLAY, and which
          # compositor is running varies. Discover the display socket at start
          # time rather than relying on each WM's session-env import, so this
          # works unchanged under sway, niri, mango, hyprland, etc.
          ExecStart = "${pkgs.writeShellScript "tmux-server" ''
            if [ -z "''${WAYLAND_DISPLAY:-}" ]; then
              i=0
              while [ $i -lt 20 ]; do
                sock=$(ls -t "''${XDG_RUNTIME_DIR:-/tmp}"/wayland-* 2>/dev/null | head -1)
                if [ -n "$sock" ]; then
                  export WAYLAND_DISPLAY="''${sock##*/}"
                  break
                fi
                i=$((i + 1))
                sleep 0.5
              done
            fi
            if [ -z "''${DISPLAY:-}" ]; then
              sock=$(ls -t /tmp/.X11-unix/X* 2>/dev/null | head -1)
              [ -n "$sock" ] && export DISPLAY=":''${sock##*X}"
            fi
            exec ${tmuxPkg}/bin/tmux start-server
          ''}";
          KillMode = "mixed";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

    };

  flake.nixosModules.tmux =
    { pkgs, config, ... }:
    {
      home-manager.users.${config.preferences.user.name} = {
        imports = [
          self.homeModules.tmux
        ];
      };

      nixpkgs.overlays = [
        inputs.tmux-nerd-font-window-name.overlays.default
      ];

      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.tmux
        self.packages.${pkgs.stdenv.hostPlatform.system}.tmuxx
      ];
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.tmux = pkgs.callPackage ../../pkgs/tmux.nix { };
      packages.tmuxx = pkgs.callPackage ../../pkgs/tmuxx.nix { };
    };
}
