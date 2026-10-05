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

    in
    {
      xdg = {
        configFile = {
          # Configuration for tmux-nerd-font-window-name: icon-only window display
          "tmux/tmux-nerd-font-window-name.yml".text =
            # yaml
            ''
              config:
                show-name: false
                # ● 
                fallback-icon: ""
                multi-pane-icon: ""
                always-show-fallback-name: false

              icons:
                tmux: ""
                television: "󰮚"
                sesh: "⚡"
                nix: ""  
                nh: ""  
                agy: "󱙺 "
                agyx: "󱙺 "
                opencode: "󱙺 "
                ocx: "󱙺 "
                claude: "󱙺 "
            '';

          # "tmux/tmux_extra.conf".source =
          #   config.lib.file.mkOutOfStoreSymlink ../../../config/tmux/tmux_extra.conf;

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

            set -s extended-keys on
            set -as terminal-features "xterm*:extkeys"

            # Bindings
            # https://github.com/tmux/tmux/wiki/Modifier-Keys#extended-keys
            bind -N "Prompt a command" : command-prompt -P
            bind -N "Fuzzy search Tmux keybindings" ? display-popup -E -w 80% -h 75% -d "#{pane_current_path}" -T "Tmux Keybindings" "tmux list-keys -N -a | tv --config-file ~/.config/television/tv-slim.toml"
            bind -N "Television sesh" "t" display-popup -E -w 80% -h 70% -d '#{pane_current_path}' -T 'Sesh' "tv sesh --hide-preview --input-position bottom"
            bind -N "Jump to urgent window or toggle last window" ` if-shell -F "#{session_alerts}" "next-window -a" "last-window"
            bind -N "Reload Configuration" R source-file ~/.config/tmux/tmux.conf \; display "Nix-managed tmux config reloaded!"
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

            # ========================
            #  UI SECTION BEGIN
            # ========================


            # Advanced Pane Movements & Inspection
            bind -N "Break pane to background window" B break-pane -d
            bind -N "Toggle marked pane" m select-pane -m
            bind -N "Join marked pane here" J join-pane
            bind -N "Inspect scrollback in Neovim" E display-popup -w 95% -h 90% -E "tmux capture-pane -p -S -3000 | nvim -c 'set buftype=nofile' -"
            bind -N "Respawn failed pane" r respawn-pane -k
            bind -N "Toggle synchronize panes" S set-window-option synchronize-panes

            # Error Preservation & History
            set -g history-file ~/.local/state/tmux/tmux_history
            set -g remain-on-exit failed-key
            set-hook -gw pane-died 'display-message "⚠️ Pane #{hook_pane} exited with failure! Press any key to close, or Prefix + r to respawn."'
            set-hook -g session-window-changed 'run-shell -b "tmux set-option -q -u -w -t \"#{hook_old_window}\" synchronize-panes"'


            bind C-y new-pane -O -c "#{pane_current_path}" -w 90% -h 90% -E "yazi" # yazi float
            # bind C-t display-popup -d "#{pane_current_path}" -w 80% -h 80% -E "zsh" # quick floating terminal
            # bind C-g display-popup -d "#{pane-current-path}" -w 90% -h 90% -E "lazygit" # lazygit float
            # bind C-m display-popup -w 95% -h 95% -E "rmpc" # music float

              # Workmux and Television Popups
              # bind C-S-s display-popup -h 30 -w 100 -E "workmux dashboard -t worktrees"
              # bind -N "Workmux dashboard" w display-popup -h 30 -w 100 -E "workmux dashboard -t worktrees"
              # bind -N "Toggle workmux sidebar" W run-shell "workmux sidebar"
              # bind -N "Television worktrees" T display-popup -E -w 80% -h 70% -d '#{pane_current_path}' -T 'Worktrees' tv git-worktrees
              # bind -N "Television tmux sessions" S display-popup -E -w 80% -h 70% -d '#{pane_current_path}' -T 'Tmux Sessions' tv tmux-sessions

              # https://medium.com/hackernoon/customizing-tmux-b3d2a5050207
              # Styles

              # Empty line before status
              set -g status-position bottom
              # set -g status-style "bg=#{@thm_bg}"
              set -wg automatic-rename on
              set -g allow-rename off
              set -g status-justify "absolute-centre"
              # Window status styling (clear default 'underscore' attribute)
              set -g window-status-style "default"
              set -g window-status-current-style "default"
              # set -g status-justify "left"
              # set -Fg "status-format[1]" "#{status-format[0]}"
              # set -g "status-format[0]" ""

              # Pane status: Only show when there are 2+ panes in a window, and align right at bottom
              set -g pane-border-status off
              set-hook -g window-layout-changed 'if-shell -F "#{>:#{window_panes},1}" "set-option -w pane-border-status bottom" "set-option -w pane-border-status off"'
              set-hook -g after-split-window    'if-shell -F "#{>:#{window_panes},1}" "set-option -w pane-border-status bottom" "set-option -w pane-border-status off"'
              set-hook -g after-kill-pane       'if-shell -F "#{>:#{window_panes},1}" "set-option -w pane-border-status bottom" "set-option -w pane-border-status off"'
              set-hook -g pane-exited           'if-shell -F "#{>:#{window_panes},1}" "set-option -w pane-border-status bottom" "set-option -w pane-border-status off"'
              set-hook -g pane-focus-in         'if-shell -F "#{>:#{window_panes},1}" "set-option -w pane-border-status bottom" "set-option -w pane-border-status off"'
              set -g pane-border-format "#[align=right]#{?pane_active,#[fg=#{@thm_crust} bg=#{@thm_mauve} bold]  #{b:pane_current_path} │  #{pane_current_command} #[default],#[fg=#{@thm_overlay_0} bg=default]  #{b:pane_current_path} │  #{pane_current_command} #[default]} "

              # Transparent Status-Left (No mantle backgrounds)
              # 1. Project name is always displayed (#{s/-.*$//:session_name})
              # 2. If session has a branch and is not main/master, normal mode shows '',
              #    while prefix mode reveals the branch name (truncated to 22 chars).
              # 3. Dynamic active command icon matches active window's icon / workmux status.
              set -g status-left-length 100
              set -g status-left ""
              set -ga status-left "#{?client_prefix,#[fg=#{@thm_green} bold]  #{s/-.*$//:session_name}#{?#{&&:#{m:*-*,#S},#{!:#{||:#{m:*-main,#S},#{m:*-master,#S}}}},  #{=/22/...:#{s/^[^-]*-//:session_name}},} ,#[fg=#{@thm_mauve} bold]  #{s/-.*$//:session_name}#{?#{&&:#{m:*-*,#S},#{!:#{||:#{m:*-main,#S},#{m:*-master,#S}}}}, ,} }"

              # Transparent Status-Right (No mantle backgrounds)
              # 1. Shows alert bell (󰂞) if any window has an alert (#{?session_alerts,...})
              # 2. In normal mode, displays only the clock for a clean, non-overlapping status bar.
              # 3. In prefix mode, swaps clock with the current directory path (truncated to 28 chars).
              set -g status-right-length 100
              set -g status-right ""
              set -ga status-right "#{?session_alerts,#[fg=#{@thm_maroon} bold]󰂞 ,}"
              set -ga status-right "#[fg=#{@thm_maroon}] #{?#{!=:${windowIcon},},${windowIcon},} #{pane_current_command} "
              set -ga status-right "#{?client_prefix,#[fg=#{@thm_blue} bold]  #{=/-28/...:#{b:pane_current_path}} ,#[fg=#{@thm_lavender}] 󰭦 %Y-%m-%d 󰅐 %H:%M }"

              # Command Prompt & Message Styling (Solid Mantle background on Ctrl+a :)

              # set -g message-style "bg=#{@thm_bg},fg=#{@thm_fg},align=centre"
              # set -g message-command-style "bg=#{@thm_mantle}, fg=#{@thm_fg},align=centre"
                set -g message-style "fg=#{@thm_fg},bg=#{@thm_mantle},align=centre"
                set -g message-command-style "fg=#{@thm_fg},bg=#{@thm_mantle},align=centre"

              # Window bell style (runs after plugins to override catppuccin's default yellow)
                set -gF window-status-bell-style "bg=#{@thm_maroon},fg=#{@thm_crust},bold"
              # Tmux 3.8: Highlight current line in copy mode
                set -gF copy-mode-current-line-style "bg=#{@thm_surface_0}"


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

                bind-key -n C-, select-window -t -1
                bind-key -n C-. select-window -t +1

                bind-key -T root C-1 select-window -t 1
                bind-key -T root C-2 select-window -t 2
                bind-key -T root C-3 select-window -t 3
                bind-key -T root C-4 select-window -t 4
                bind-key -T root C-5 select-window -t 5
                bind-key -T root C-6 select-window -t 6
                bind-key -T root C-7 select-window -t 7
                bind-key -T root C-8 select-window -t 8
                bind-key -T root C-9 select-window -t 9

              # =============================================================================
              # Named scratch buffers
              #
              # A scratch buffer is a floating pane you give a name to. It can be minimized
              # (parked back into the `scratch` session, keeping its process and history) and
              # spawned again into any window of any session. `prefix + b` opens the group.
              #
              #   b n   new buffer    - prompt for a name, then spawn it here
              #   b s   spawn buffer  - pick an existing buffer from a menu
              #   b m   minimize      - send the active buffer back to the stash
              #   b k   kill buffer   - pick a buffer to kill
              #   b l   list buffers  - show name and state of each
              # =============================================================================

              # `switch-client -T` consumes exactly one following key and then returns the
              # client to its normal table, so C-a b n, C-a b s and so on work as a group.
              # Escape is bound so the group can be cancelled without typing into the pane.
              bind -N "Scratch: group" -T prefix b switch-client -T scratch

              # The whole invocation must survive as ONE quoted token. That is load bearing:
              # `run-shell` parses its own command line, and its trailing `[argument ...]`
              # values are only ever exposed as `#{1}`, `#{2}` - they are never appended to
              # shell-command. Written as separate tokens:
              #
              #   run-shell -b .../scratch new %% #{window_id}      <- args silently dropped
              #   run-shell -b '.../scratch new %% #{window_id}'    <- correct
              #
              # The first form runs the script with no arguments at all, which falls into the
              # usage branch - the binding just looks dead, and the usage text it prints goes
              # to a stdout that `run-shell -b` throws away. The same rule applies to the
              # display-menu item commands inside the script.
              #
              # Single quotes rather than escaped double quotes: tmux's config parser keeps a
              # ' inside a "..." token verbatim, and command-prompt then re-parses the string
              # and honours them.
              #
              # command-prompt substitutes `%%` with the typed name, and -F expands
              # `#{window_id}` to the window the prompt was opened in.
              bind -N "Scratch: new buffer" -T scratch n \
                  command-prompt -P -F -p 'buffer name: ' \
                  "run-shell -b '$HOME/.config/tmux/scripts/scratch new %% #{window_id}'"

              # Same single-token rule as above: the arguments have to live inside the quotes.
              bind -N "Scratch: spawn buffer" -T scratch s \
                  run-shell -b "$HOME/.config/tmux/scripts/scratch pick #{window_id}"

              bind -N "Scratch: minimize buffer" -T scratch m \
                  run-shell -b "$HOME/.config/tmux/scripts/scratch minimize"

              bind -N "Scratch: kill buffer" -T scratch k \
                  run-shell -b "$HOME/.config/tmux/scripts/scratch kill-menu"

              bind -N "Scratch: list buffers" -T scratch l \
                  run-shell -b "$HOME/.config/tmux/scripts/scratch list"

              bind -N "Scratch: cancel" -T scratch Escape switch-client -T root

              # Forget a buffer whose pane exited so the status indicator below cannot go
              # stale.
              #
              # These go in named array slots on purpose. A plain `set-hook -g` would replace
              # the whole array, and the main config already sets pane-exited for pane border
              # status, so that would silently disable it. Naming the slot also makes
              # re-sourcing this file idempotent instead of appending a duplicate every time.
              #
              # Which one fires depends on remain-on-exit: with it on (failed-key) a dying
              # pane lingers and pane-died fires, with it off the pane is destroyed and
              # pane-exited fires. Both are registered; reap is a no-op while the pane is
              # still around.
              #
              # A pane destroyed with kill-pane fires neither, which is why the script also
              # prunes vanished panes itself on every invocation.
              #
              # No #{hook_pane} here on purpose: tmux expands hook formats while it is still
              # parsing this file, where there is no pane to name, so it would arrive as an
              # empty argument. `reap` takes none and prunes the whole registry instead.
              set-hook -g 'pane-exited[scratch]' \
                  "run-shell -b $HOME/.config/tmux/scripts/scratch reap"

              set-hook -g 'pane-died[scratch]' \
                  "run-shell -b $HOME/.config/tmux/scripts/scratch reap"

              # Status right indicator: only shown while buffers exist.
              set -ga status-right "#{?#{@scratch_count},#[fg=#{@thm_mauve},bold] ⌗ #{@scratch_list} ,}"



              # ========================
              #  UI SECTION END
              # ========================
              # Hook to run fastfetch on window creation if there's only one window
              # set-hook -g after-new-session 'send-keys " clear && fastfetch" C-m'

              # set -g @continuum-restore "on"
              source -F $HOME/.config/tmux/dev.tmux..conf
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
                set -g @catppuccin_pane_active_border_style "##{?pane_in_mode,fg=#{@thm_yellow},##{?pane_synchronized,fg=#{@thm_rosewater},fg=#{@thm_mauve}}}"
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
                set -g @catppuccin_window_current_text "#{?window_bell_flag,#[fg=#{@thm_crust} bg=#{@thm_maroon} bold] #{?client_prefix,${kanjiIndex} ,} ${windowIcon} #[default],#[fg=#{@thm_crust} bg=#{@thm_blue} bold] #{?client_prefix,${kanjiIndex} ,}${windowIcon} }"


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

          # sensible

          # {
          #   # https://github.com/alexwforsythe/tmux-which-key#nix-with-home-manager-flake-installation
          #   plugin = tmux-which-key;
          #
          #   extraConfig =
          #     # sh
          #     ''
          #       # Enables XDG user directory support for the plugin.
          #       set -g @tmux-which-key-xdg-enable 1;
          #
          #       # Disables building the tmux configuration from YAML everytime the plugin starts.
          #       # The home manager module calls `plugin/build.py` on each generation.
          #       set -g @tmux-which-key-disable-autobuild 1
          #
          #       # Follows nixpkgs prefered path for plugins instead of the default
          #       # path of $XDG_*_HOME/tmux/plugins/tmux-which-key.
          #       set -g @tmux-which-key-xdg-plugin-path tmux-plugins/tmux-which-key
          #     '';
          # }

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
      ];
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.tmux = pkgs.callPackage ../../pkgs/tmux.nix { };
    };
}
