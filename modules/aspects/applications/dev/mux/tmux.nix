# Tmux Aspect with Plugins, Status Bar, and Systemd Socket Autostart
{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    tmux-nerd-font-window-name.url = "github:joshmedeski/tmux-nerd-font-window-name";
    tmux-remux.url = "github:noamsto/tmux-remux";
  };

  den.aspects.applications.dev.mux.tmux = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          (pkgs.local.tmux or pkgs.tmux)
        ]
        ++ lib.optional (pkgs ? local && pkgs.local ? tmuxx) pkgs.local.tmuxx;
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
        tmux-fzf-links = pkgs.tmuxPlugins.mkTmuxPlugin {
          pluginName = "tmux-fzf-links";
          rtpFilePath = "fzf-links.tmux";

          src = pkgs.fetchFromGitHub {
            owner = "alberti42";
            repo = "tmux-fzf-links";
            sha256 = "1jb9zvnzn494m03b6kizazpibdhqvfjywy9shs1p838jafbn6f5c";
            tag = "1.5.1";
          };

          version = "1.5.1";
        };
        tmux-menus = pkgs.tmuxPlugins.mkTmuxPlugin {
          pluginName = "tmux-menus";
          rtpFilePath = "menus.tmux";

          src = pkgs.fetchFromGitHub {
            hash = "sha256-C2rFzuR12ap2ytX03XaBycNia3vzaexFdOFM3qrSsUw=";
            owner = "jaclu";
            repo = "tmux-menus";
            rev = "30a18ec5e949db228f1596937880e494a7be49ef";
          };

          version = "0-unstable-2026-10-02";
        };
        tmuxPkg = pkgs.local.tmux or pkgs.tmux;
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
              bind -N "Fuzzy search Tmux keybindings" ? display-popup -E -w 80% -h 75% -d "#{pane_current_path}" -T "Tmux Keybindings" "tmux list-keys -N -a | tv --config-file ~/.config/television/tv-slim.toml"
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

              set -g @window_icon "${windowIcon}"
              source -F "$HOME/.config/tmux/status.tmux.conf"
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
                  resurrect_dir=$HOME/.local/state/tmux/resurrect/
                  set -g @resurrect-dir $resurrect_dir
                  set -g @resurrect-hook-post-save-all "sed -i 's| --cmd .*-vim-pack-dir||g; s|/etc/profiles/per-user/$USER/bin/||g; s|/nix/store/.*/bin/||g' $(readlink -f $resurrect_dir/last)"

                  set -g @resurrect-save "C-S"
                  set -g @resurrect-restore "C-R"
                '';

              plugin = resurrect;
            }
            {
              extraConfig =
                # sh
                ''
                  set -g @continuum-save-interval "5"
                  set -g @continuum-restore "on"
                '';

              plugin = continuum;
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
              exec ${tmuxPkg}/bin/tmux start-server
            ''}";

            KillMode = lib.mkDefault "mixed";
            Type = lib.mkDefault "forking";
          };

          Unit = {
            After = [ "graphical-session.target" ];
            Description = "tmux server (continuum auto-restore)";
            Documentation = "man:tmux(1)";
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

        src = pkgs.fetchFromGitHub {
          hash = "sha256-xUYIpIOKzfd34+KlwQjPhmfE1qUbDJ8IvcL0bZy5CH8=";
          owner = "tmux";
          repo = "tmux";
          rev = "2b5b538152a1ecdeac4c080f77f6af062349bdb7";
        };

        version = "0-unstable-2026-10-05";

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
