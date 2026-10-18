# Tmux Aspect with Plugins, Status Bar, and Systemd Socket Autostart
{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    tmux-fzf-links = {
      flake = false;
      url = "github:alberti42/tmux-fzf-links";
    };

    tmux-menus = {
      flake = false;
      url = "github:jaclu/tmux-menus";
    };

    tmux-nerd-font-window-name.url = "github:joshmedeski/tmux-nerd-font-window-name";
    tmux-remux.url = "github:noamsto/tmux-remux";

    tmux-src = {
      flake = false;
      url = "github:tmux/tmux";
    };
  };

  den.aspects.applications.dev.mux.tmux = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          (pkgs.local.tmux or pkgs.tmux)
        ]
        ++ lib.optional (pkgs ? local && pkgs.local ? tmuxx) pkgs.local.tmuxx
        ++ lib.optionals (pkgs ? nur && pkgs.nur ? repos && pkgs.nur.repos ? Freed-Wu) [
          pkgs.nur.repos.Freed-Wu.tree-sitter-tmux
          pkgs.nur.repos.Freed-Wu.tmux-language-server
          pkgs.nur.repos.Freed-Wu.termux-language-server
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
        dotfilesTmux = "${dotsPath}/tmux";
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
        kanjiIndex = "#{?#{==:#I,1},一,#{==:#I,2},二,#{==:#I,3},三,#{==:#I,4},四,#{==:#I,5},五,#{==:#I,6},六,#{==:#I,7},七,#{==:#I,8},八,#{==:#I,9},九,#{==:#I,10},十,#I}";
        resurrectDir = "${config.home.homeDirectory}/.local/state/tmux/resurrect";
        tmux-fzf-links = pkgs.tmuxPlugins.mkTmuxPlugin {
          pluginName = "tmux-fzf-links";
          rtpFilePath = "fzf-links.tmux";

          src =
            inputs.tmux-fzf-links or (pkgs.fetchFromGitHub {
              owner = "alberti42";
              repo = "tmux-fzf-links";
              sha256 = "1jb9zvnzn494m03b6kizazpibdhqvfjywy9shs1p838jafbn6f5c";
              tag = "1.5.1";
            });

          version = "1.5.1";
        };
        tmux-menus = pkgs.tmuxPlugins.mkTmuxPlugin {
          pluginName = "tmux-menus";
          rtpFilePath = "menus.tmux";

          src =
            inputs.tmux-menus or (pkgs.fetchFromGitHub {
              hash = "sha256-C2rFzuR12ap2ytX03XaBycNia3vzaexFdOFM3qrSsUw=";
              owner = "jaclu";
              repo = "tmux-menus";
              rev = "30a18ec5e949db228f1596937880e494a7be49ef";
            });

          version = "0-unstable-${inputs.tmux-menus.lastModifiedDate or "2026-10-02"}";
        };
        tmuxPkg = pkgs.local.tmux or pkgs.tmux;
        tmuxResurrectRestore = pkgs.writeShellScript "tmux-resurrect-restore" ''
          export PATH="${
            lib.makeBinPath [
              tmuxPkg
              pkgs.coreutils
              pkgs.findutils
              pkgs.gnugrep
              pkgs.gnused
              pkgs.gawk
              pkgs.procps
              pkgs.util-linux
              pkgs.diffutils
            ]
          }:$PATH"
          resurrect_dir="${resurrectDir}"
          mkdir -p "$resurrect_dir"

          exec 9>"$resurrect_dir/.restore.lock"
          ${pkgs.util-linux}/bin/flock -n 9 || exit 0

          # Self-heal `last` symlink before restore if missing, dangling, or empty
          if [ ! -f "$resurrect_dir/last" ] || ! grep -q '^pane' "$resurrect_dir/last" 2>/dev/null; then
            for candidate in $(ls -1t "$resurrect_dir"/tmux_resurrect_*.txt 2>/dev/null); do
              if grep -q '^pane' "$candidate" 2>/dev/null; then
                ln -sf "$(basename "$candidate")" "$resurrect_dir/last"
                break
              fi
            done
          fi

          if [ -f "$resurrect_dir/last" ] && grep -q '^pane' "$resurrect_dir/last" 2>/dev/null; then
            ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/restore.sh "$@"
            ${tmuxPkg}/bin/tmux set-option -gq "@continuum-save-last-timestamp" "$(date +%s)" 2>/dev/null || true
          fi
        '';
        tmuxResurrectSave = pkgs.writeShellScript "tmux-resurrect-save" ''
          export PATH="${
            lib.makeBinPath [
              tmuxPkg
              pkgs.coreutils
              pkgs.findutils
              pkgs.gnugrep
              pkgs.gnused
              pkgs.gawk
              pkgs.procps
              pkgs.util-linux
              pkgs.diffutils
            ]
          }:$PATH"
          resurrect_dir="${resurrectDir}"
          mkdir -p "$resurrect_dir"

          # Serialize all save operations so concurrent saves never race on `last`
          exec 9>"$resurrect_dir/.save.lock"
          ${pkgs.util-linux}/bin/flock -n 9 || exit 0

          # Refuse to save when server has no live panes (e.g., empty server or teardown)
          pane_count="$(${tmuxPkg}/bin/tmux list-panes -a 2>/dev/null | wc -l | tr -d ' ')"
          if [ -z "$pane_count" ] || [ "$pane_count" -eq 0 ]; then
            exit 0
          fi

          # Avoid same-second collision with `last` where save.sh's `files_differ`
          # compares the freshly overwritten file against `last` (itself) and deletes it
          now_file="tmux_resurrect_$(date +"%Y%m%dT%H%M%S").txt"
          if [ -L "$resurrect_dir/last" ] && [ "$(readlink "$resurrect_dir/last")" = "$now_file" ]; then
            sleep 1
          fi

          ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh "$@"

          # Self-heal `last` symlink if missing, dangling, or pointing to a file without panes
          if [ ! -f "$resurrect_dir/last" ] || ! grep -q '^pane' "$resurrect_dir/last" 2>/dev/null; then
            for candidate in $(ls -1t "$resurrect_dir"/tmux_resurrect_*.txt 2>/dev/null); do
              if grep -q '^pane' "$candidate" 2>/dev/null; then
                ln -sf "$(basename "$candidate")" "$resurrect_dir/last"
                break
              fi
            done
          fi
        '';
        windowIcon = "#{?#{&&:#{!=:#{@workmux_status},},#{||:#{m:*●*,#W},#{m:**,#W},#{m:*󱚟*,#W},#{m:*󱙺*,#W}}},#{@workmux_status},#W#{?@workmux_status, #{@workmux_status},}}";
      in
      {
        programs.tmux = {
          aggressiveResize = true;
          baseIndex = 1;
          clock24 = true;
          customPaneNavigationAndResize = true;
          enable = true;
          escapeTime = 100;

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
              set -as terminal-features ",xterm-ghostty:RGB"
              set -as terminal-features ",xterm-256color:RGB"

              # Extended keys
              set -s extended-keys on
              set -as terminal-features "xterm*:extkeys"

              # Bindings
              bind -N "Prompt a command" : command-prompt -P
              bind -N "Fuzzy search Tmux keybindings" ? display-popup -E -w 80% -h 75% -d "#{pane_current_path}" -T "Tmux Keybindings" "tmux list-keys -N -a | tv --layout portrait --hide-preview --input-position bottom"
              bind -N "Television sesh" "t" display-popup -E -w 80% -h 70% -d '#{pane_current_path}' -T 'Sesh' "tv sesh --hide-preview --input-position bottom"
              bind -N "Jump to urgent window or toggle last window" ` if-shell -F "#{session_alerts}" "next-window -a" "last-window"
              bind -N "Reload Configuration" R source-file "~/.config/tmux/tmux.conf" \; display "Nix-managed tmux config reloaded!"
              bind -N "Copy selection" -T copy-mode-vi y send -X copy-pipe-and-cancel "wl-copy"
              bind -N "Create window" c new-window -c "#{pane_current_path}"
              bind -N "Create window cwd" C new-window
              bind -N "Display Clock" C-t clock-mode
              bind -N "Kill pane" x kill-pane
              bind -N "Kill window" q confirm-before -p "Kill window #W? (y/n)" kill-window
              bind -N "Kill session" X confirm-before -p "Kill session #S? (y/n)" kill-session
              bind -N "Split pane vertically" - split-window -v -c "#{pane_current_path}"
              bind -N "Split pane horizontally" \| split-window -h -c "#{pane_current_path}"

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

              # Keep tmux server alive without open sessions so systemd service stays running
              # and continuum auto-restore has time to restore sessions on boot
              set -s exit-empty off

              # Override resurrect save/restore scripts and bindings with lock-protected self-healing wrappers
              set -g @resurrect-save-script-path "${tmuxResurrectSave}"
              set -g @resurrect-restore-script-path "${tmuxResurrectRestore}"
              bind-key C-S run-shell "${tmuxResurrectSave}"
              bind-key C-R run-shell "${tmuxResurrectRestore}"

              # Save on client detach as well as periodic interval (use -g, not -ga, so config reloads do not duplicate hooks)
              set-hook -g client-detached "run-shell -b '${tmuxResurrectSave} quiet'"

              set -g @window_icon "${windowIcon}"
              source -F "$HOME/.config/tmux/status.tmux.conf"
              # Configure and run continuum once after status.tmux.conf so status-right interpolation is preserved
              # and continuum_restore.sh is only spawned once on startup
              set -g @continuum-save-interval "5"
              set -g @continuum-restore "on"
              run-shell "${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum/continuum.tmux"
            '';

          focusEvents = true;
          historyLimit = 1000000;
          keyMode = "vi";
          mouse = true;
          package = tmuxPkg;

          plugins = [
            {
              extraConfig =
                # sh
                ''
                  set -g @tmux-nerd-font-window-name-config-file "$HOME/.config/tmux/tmux-nerd-font-window-name.yml"
                  set -g automatic-rename-format "#{window_icon}"
                '';

              plugin = pkgs.tmuxPlugins.tmux-nerd-font-window-name;
            }
            {
              extraConfig =
                # sh
                ''
                  set -g @fzf-links-key "u"
                  set -g @fzf-links-python "${pkgs.python3}/bin/python3"
                  set -g @fzf-links-browser-open-cmd "zen-beta '%url'"
                  set -g @fzf-links-editor-open-cmd "tmux new-window -n 'nvim' nvim +%line '%file'"
                '';

              plugin = tmux-fzf-links;
            }
            {
              extraConfig =
                # sh
                ''
                  set -g @menus_use_cache "No"
                  set -g @menus_trigger '\'
                '';

              plugin = tmux-menus;
            }
          ]
          ++ (with pkgs.tmuxPlugins; [
            {
              extraConfig =
                # sh
                ''
                  set -g @catppuccin_flavor "mocha"
                  set -g @catppuccin_status_background "none"
                  set -g @catppuccin_status_left_separator ""
                  set -g @catppuccin_status_right_separator ""
                  set -g @catppuccin_window_middle_separator ""

                  set -g @catppuccin_pane_status_enabled "off"
                  set -g @catppuccin_pane_border_status "off"
                  set -g @catppuccin_pane_active_border_style "##{?pane_in_mode,fg=#{@thm_mauve},##{?pane_synchronized,fg=#{@thm_rosewater},fg=#{@thm_mauve}}}"
                  set -g @catppuccin_pane_color "#{@thm_overlay_0}"

                  set -g @catppuccin_window_status_style "custom"
                  set -g @catppuccin_window_flags ""
                  set -g @catppuccin_window_number ""

                  set -g @catppuccin_window_text "#{?window_bell_flag,#[fg=#{@thm_crust} bg=#{@thm_maroon} bold] #{?client_prefix,${kanjiIndex} ,} ${windowIcon} #[default],#[fg=#{@thm_mauve} bg=default] #{?client_prefix,${kanjiIndex} ,}${windowIcon} }"
                  set -g @catppuccin_window_current_number ""
                  set -g @catppuccin_window_current_text "#{?window_bell_flag,#[fg=#{@thm_crust} bg=#{@thm_maroon} bold]  ${windowIcon} #[default],#[fg=#{@thm_crust} bg=#{@thm_blue} bold] ${windowIcon} }"
                '';

              plugin = catppuccin;
            }
            {
              extraConfig =
                # sh
                ''
                  set -g @resurrect-strategy-vim "session"
                  set -g @resurrect-strategy-nvim "session"
                  set -g @resurrect-processes "lazydocker lazygit yazi"
                  set -g @resurrect-dir "${resurrectDir}"
                  set -g @resurrect-hook-post-save-layout "sed -i 's| --cmd .*-vim-pack-dir||g; s|/etc/profiles/per-user/$USER/bin/||g; s|/nix/store/.*/bin/||g'"

                  set -g @resurrect-save "C-S"
                  set -g @resurrect-restore "C-R"
                '';

              plugin = resurrect;
            }
          ]);

          prefix = "C-a";
          shortcut = "a";
          terminal = "tmux-256color";
        };

        systemd.user.services.tmux-server = {
          Install.WantedBy = [ "graphical-session.target" ];

          Service = {
            Environment = [ "TMUX_TMPDIR=%t" ];

            ExecStart = lib.mkDefault "${pkgs.writeShellScript "tmux-server" ''
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
              ${tmuxPkg}/bin/tmux start-server
              if ! ${tmuxPkg}/bin/tmux list-sessions >/dev/null 2>&1; then
                ${tmuxResurrectRestore} >/dev/null 2>&1 || true
              fi
            ''}";

            ExecStop = "${pkgs.writeShellScript "tmux-stop" ''
              ${tmuxPkg}/bin/tmux run-shell "${tmuxResurrectSave} quiet" 2>/dev/null || true
            ''}";

            KillMode = lib.mkDefault "mixed";
            RemainAfterExit = lib.mkDefault true;
            Restart = lib.mkDefault "on-failure";
            Type = lib.mkDefault "forking";
          };

          Unit = {
            After = [ "graphical-session.target" ];
            Description = "tmux server (continuum auto-restore)";
            Documentation = "man:tmux(1)";
            X-RestartIfChanged = false;
            X-StopIfChanged = false;
          };
        };

        xdg.configFile = {
          "tmux/scripts" = {
            force = true;
            source = config.lib.file.mkOutOfStoreSymlink "${dotfilesTmux}/scripts";
          };

          "tmux/status.tmux.conf".source =
            config.lib.file.mkOutOfStoreSymlink "${dotfilesTmux}/status.tmux.conf";

          "tmux/tmux-nerd-font-window-name.yml".source =
            config.lib.file.mkOutOfStoreSymlink "${dotfilesTmux}/tmux-nerd-font-window-name.yml";
        };
      };

    nixpkgs-overlays =
      _:
      lib.optionals (inputs ? tmux-nerd-font-window-name) [
        (final: prev: {
          tmuxPlugins = prev.tmuxPlugins // {
            tmux-nerd-font-window-name =
              inputs.tmux-nerd-font-window-name.packages.${final.stdenv.hostPlatform.system}.default;
          };
        })
      ];

    persistHome.directories = [
      ".local/share/tmux"
      ".local/state/tmux"
    ];
  };

  perSystem =
    { pkgs, ... }:
    let
      tmux = pkgs.tmux.overrideAttrs (_oldAttrs: rec {
        pname = "tmux";

        src = pkgs.fetchurl {
          hash = "sha256-55xpnH6UnczQpKEl4XuNEmHjEbFpedvI6zRULzlm2C4=";
          url = "https://github.com/tmux/tmux/releases/download/${version}/tmux-${version}.tar.gz";
        };

        version = "3.8";
      });

      tmuxx = tmux.overrideAttrs (oldAttrs: {
        # git builds report `tmux -V` as "next-3.x", failing versionCheckHook
        doInstallCheck = false;
        pname = "tmuxx";

        # NOTE: plugins that shell out to `tmux` (e.g. tmux-menus via TMUX_BIN) will
        # use the 3.8-rc3 client against this next-3.9 server. If something
        # misbehaves under tmuxx, launch with: TMUX_BIN=tmuxx tmuxx
        postInstall = (oldAttrs.postInstall or "") + ''
          mv $out/bin/tmux $out/bin/tmuxx
          mv $man/share/man/man1/tmux.1 $man/share/man/man1/tmuxx.1
        '';

        src =
          inputs.tmux-src or (pkgs.fetchFromGitHub {
            hash = "sha256-xUYIpIOKzfd34+KlwQjPhmfE1qUbDJ8IvcL0bZy5CH8=";
            owner = "tmux";
            repo = "tmux";
            rev = "2b5b538152a1ecdeac4c080f77f6af062349bdb7";
          });

        version = "0-unstable-${inputs.tmux-src.lastModifiedDate or "2026-10-05"}";

        meta = oldAttrs.meta // {
          mainProgram = "tmuxx";
        };
      });
    in
    {
      packages = {
        inherit tmux tmuxx;
      };
    };
}
