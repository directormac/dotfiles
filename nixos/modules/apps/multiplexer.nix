{ inputs, self, ... }: {
  flake.homeModules.multiplexer =
    { pkgs, config, ... }:
    let

      # storeSymLink = config.lib.file.mkOutOfStoreSymlink;

      /**
        ## NOTE: fetchFromGitHub

        `rev` or `tag` is required

         Obtaining rev
        ```sh
        git ls-remote https://github.com/owner/repo HEAD
        ```
        Copy the output.

        `sha256` sha256 is a hash of the unpacked file tree, not a git thing.
         You never have to compute it by hand — put in a fake value and Nix tells you the real one:

        After obtaining the rev you can run this for fake sha256
        ```sh
        nix build --impure --no-link --expr 'let p = import <nixpkgs> {}; in p.fetchFromGitHub {
          owner = "owner"; repo = "repo";
          rev = "the rev";
          sha256 = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        }'
        ```
        it will return the correct sha256

        Then hash it to nix32
        ```sh
        nix hash convert --to nix32 <correct-sha256>
        ```

        Quick Command

        ```sh
        nix eval --impure --json --expr 'let t = builtins.fetchTree {
          type = "github"; owner = "owner"; repo = "repo";
        }; in { rev = t.rev; hash = t.narHash; }'
        ```
      */
      tmux-menus = pkgs.tmuxPlugins.mkTmuxPlugin {
        pluginName = "tmux-menus";
        # rev is ahead of the latest tag (v2.4.1); no upstream release to name it after
        version = "unstable";
        # Upstream entrypoint is menus.tmux, not the derived tmux_menus.tmux
        rtpFilePath = "menus.tmux";
        src = pkgs.fetchFromGitHub {
          owner = "jaclu";
          repo = "tmux-menus";
          rev = "1c3372d489a10907d2dff7731e0a10246b7a6a81";
          sha256 = "0xh8f3bd03crsdhnpsqwb5b57hj720k67n45nckdkvdm1yjkl3fx";
        };
      };
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

      home.packages = [ inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default ];

      # https://workmux.raine.dev/guide/configuration/
      xdg.configFile."workmux/config.yaml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/workmux/config.yaml";

      # Television cable for workmux
      xdg.configFile."television/cable/workmux.toml".text =
        # toml
        ''
          [metadata]
          name = "workmux"
          description = "List and switch between workmux worktrees"
          requirements = ["workmux", "jq"]

          [source]
          command = "workmux list --json 2>/dev/null | jq -r '.[] | .handle + \"\\t\" + .branch + \"\\t\" + .path'"

          [preview]
          command = "cd '{split:\\t:2}' 2>/dev/null && git log --oneline -10 --color=always && echo && git status --short"

          [keybindings]
          enter = "actions:open"
          ctrl-d = "actions:close"

          [actions.open]
          description = "Open or switch to selected worktree in tmux"
          command = "workmux open '{split:\\t:0}'"
          mode = "fork"

          [actions.close]
          description = "Close the selected worktree window/session"
          command = "workmux close '{split:\\t:0}'"
          mode = "fork"
        '';

      xdg.configFile."television/cable/git-worktrees.toml".text =
        # toml
        ''
          [metadata]
          name = "git-worktrees"
          description = "List and switch between git worktrees"
          requirements = ["git"]

          [source]
          command = "git worktree list --porcelain | grep '^worktree' | cut -d' ' -f2-"

          [preview]
          command = "cd '{}' && git log --oneline -10 --color=always && echo && git status --short"

          [keybindings]
          enter = "actions:cd"
          ctrl-d = "actions:remove"

          [actions.cd]
          description = "Change to the selected worktree"
          command = "cd {} && $SHELL"
          mode = "execute"

          [actions.remove]
          description = "Remove the selected worktree"
          command = "git worktree remove {}"
          mode = "execute"
        '';

      # [sesh.nix](https://github.com/nix-community/home-manager/blob/master/modules/programs/sesh.nix)
      programs.sesh = {
        enable = true;
        enableAlias = true;

        # See the [sesh documentation](https://github.com/joshmedeski/sesh#configuration) for available options.
        settings = {
          wildcard = [
            {
              pattern = "~/Projects/*";
              windows = [
                "editor"
                "terminal"
              ];
            }
            {
              pattern = "~/Code/.worktrees/*/*";
              windows = [
                "editor"
                "terminal"
                "lazygit"
              ];
            }
          ];
          session = [
            {
              name = "Dotfiles";
              path = "~/.dotfiles";
            }
            {
              name = "Config";
              path = "~/.dotfiles/config";
            }
            {
              name = "Default";
              path = "~/";
            }
          ];
          window = [
            {
              name = "editor";
              startup_script = "nvim";
            }
            {
              name = "terminal";
              startup_script = "clear";
            }
            {
              name = "lazygit";
              startup_script = "lazygit";
            }
            {
              name = "agent";
              startup_script = "agy";
            }
          ];
        };
      };

      programs.tmux = {
        enable = true;
        prefix = "C-a";
        shortcut = "a";
        clock24 = true;
        baseIndex = 1;
        keyMode = "vi";
        # newSession = true;
        mouse = true;
        escapeTime = 100;
        historyLimit = 1000000;

        # Pieces of config from our config/tmux.conf
        extraConfig =
          # conf
          ''
            # Must not overide with neovim and terminal emulator keys
            # Reference https://github.com/tmux/tmux/wiki/Modifier-Keys
            unbind C-b

            set -g base-index 1 # index of tabs starts at 1
            set -g pane-base-index 1 # inex of pane must also start at 1
            set-window-option -g pane-base-index 1 # Base window number?
            set-option -g renumber-windows on # Renumber windows on remove

            set -g history-limit 100000
            #Set Refresh every Second
            set-option -g status-interval 1


            # Dont exit from tmux when closing session
            # Sesh Recommendation
            set -g detach-on-destroy off

            # Required by tmux-nerd-font-window-name
            set -g allow-rename off

            set -g default-terminal "tmux-256color"

            set -s set-clipboard on

            # Linux Wayland (wl-clipboard)
            bind-key -N "Begin selection" -T copy-mode-vi v send-keys -X begin-selection
            bind-key -N "Copy selection"  -T copy-mode-vi y send-keys -X copy-selection-and-cancel
            bind -N "Copy selection" -T copy-mode-vi y send -X copy-pipe-and-cancel "wl-copy"

            # Tell tmux that the *outside* terminal (Ghostty/Alacritty/etc.) supports True Color (RGB)
            # This works for Ghostty (which uses xterm-ghostty) and others using xterm-256color
            set -as terminal-features ",xterm-ghostty:RGB"
            set -as terminal-features ",xterm-256color:RGB"


            bind -N "Create window" c new-window -c "#{pane_current_path}"
            bind -N "Create window cwd" C new-window

            # Clock mode
            bind C-t clock-mode

            # Key bind section all key assignments below must use Prefix-key
            # Prefix key is default <C-a>
            #Vim style pane selection <Prefix-key>
            bind -N "Focus pane left" h select-pane -L
            bind -N "Focus pane down" j select-pane -D
            bind -N "Focus pane up" k select-pane -U
            bind -N "Focus pane right" l select-pane -R

            # Vim style pane resizing (No Prefix-key needed)
            bind -N "Resize pane left"  -n C-M-S-h resize-pane -L 5
            bind -N "Resize pane down"  -n C-M-S-j resize-pane -D 5
            bind -N "Resize pane up"    -n C-M-S-k resize-pane -U 5
            bind -N "Resize pane right" -n C-M-S-l resize-pane -R 5

            bind -N "Resize pane left" -n C-M-S-Left resize-pane -L 5
            bind -N "Resize pane down" -n C-M-S-Down resize-pane -D 5
            bind -N "Resize pane up" -n C-M-S-Up resize-pane -U 5
            bind -N "Resize pane right" -n C-M-S-Right resize-pane -R 5

            # bind -N "Kill pane" x confirm-before -p "Kill pane #P? (y/n)" kill-pane
            unbind x
            bind -N "Kill pane" x kill-pane
            bind -N "Kill window" q confirm-before -p "Kill window #W? (y/n)" kill-window
            bind -N "Kill session" X confirm-before -p "Kill session #S? (y/n)" kill-session

            # Quick reload shortcut
            bind R source-file ~/.config/tmux/tmux.conf \; display "Nix-managed tmux config reloaded!"

            bind -N "Split pane vertically" - split-window -v -c "#{pane_current_path}"
            # bind -N "Split pane vertically" -n M-Enter split-window -v -c "#{pane_current_path}"

            bind -N "Split pane horizontally" \| split-window -h -c "#{pane_current_path}" #split to current path
            # bind -N "Split pane horizontally" -n C-M-S-Enter split-window -h -c "#{pane_current_path}"

            # Workmux and Television Popups
            # bind C-S-s display-popup -h 30 -w 100 -E "workmux dashboard -t worktrees"
            # bind -N "Workmux dashboard" w display-popup -h 30 -w 100 -E "workmux dashboard -t worktrees"
            # bind -N "Toggle workmux sidebar" W run-shell "workmux sidebar"
            # bind -N "Television worktrees" T display-popup -E -w 80% -h 70% -d '#{pane_current_path}' -T 'Worktrees' tv git-worktrees
            # bind -N "Television tmux sessions" S display-popup -E -w 80% -h 70% -d '#{pane_current_path}' -T 'Tmux Sessions' tv tmux-sessions
            bind-key -N "Television sesh" "t" display-popup -E -w 80% -h 70% -d '#{pane_current_path}' -T 'Sesh' tv sesh


            set -g @continuum-restore 'on'
          '';
        plugins = [
          # https://github.com/joshmedeski/tmux-nerd-font-window-name#nix-flakes
          inputs.tmux-nerd-font-window-name.packages.${pkgs.stdenv.hostPlatform.system}.default
          # https://github.com/jaclu/tmux-menus
          # {
          #   plugin = tmux-menus;
          # }
          # https://github.com/alberti42/tmux-fzf-links
          {
            plugin = tmux-fzf-links;
          }
        ]
        ++ (with pkgs.tmuxPlugins; [
          # catppuccin
          {
            plugin = catppuccin;
            extraConfig =
              # config
              ''
                # Reference https://github.com/catppuccin/tmux/blob/main/docs/reference/configuration.md

                set -g @catppuccin_flavor 'mocha' # latte,frappe, macchiato or mocha
                set -g @catppuccin_window_status_style "basic"
                set -g @catppuccin_status_left_separator "█"
                set -g @catppuccin_status_right_separator "█"
                # set -g @catppuccin_date_time_text "%Y-%m-%d %H:%M:%S"
                set -g @catppuccin_status_background "none"

                # Mauve Overrides for a consistent look
                set -g @catppuccin_window_current_number_color "#cba6f7"
                set -g @catppuccin_directory_color "#cba6f7"
                set -g @catppuccin_session_color "#cba6f7"

                ### Plugin: https://github.com/catppuccin/tmux
                set-option -g @catppuccin_window_number_position 'left'
                set-option -g @catppuccin_window_flags 'no'
                set-option -g @catppuccin_window_text ' #W'
                set-option -g @catppuccin_window_current_text ' #W'
                set-option -g @catppuccin_status_middle_separator ""

                set -g status-left ""
                set -g status-right-length 100
                set -g status-right "#{E:@catppuccin_status_directory}"
                set -ag status-right "#{E:@catppuccin_status_session}"
                # set -ag status-right "#{E:@catppuccin_status_date_time}"
                set -g @catppuccin_status_background "none"
              '';
          }
          {
            plugin = fzf-tmux-url;
            extraConfig = ''
              set -g @fzf-url-bind 'o'
            '';
          }
          {
            plugin = resurrect;
            extraConfig = ''
              set -g @resurrect-strategy-vim 'session'
              set -g @resurrect-strategy-nvim 'session'
              set -g @resurrect-capture-pane-contents 'on'
              resurrect_dir=$HOME/.local/state/tmux/resurrect/
              set -g @resurrect-dir $resurrect_dir
              set -g @resurrect-hook-post-save-all "sed -i 's| --cmd .*-vim-pack-dir||g; s|/etc/profiles/per-user/$USER/bin/||g; s|/nix/store/.*/bin/||g' $(readlink -f $resurrect_dir/last)"
              set -g @resurrect-save 'C-s'
              set -g @resurrect-restore 'C-r'
            '';
          }

          {
            plugin = continuum;
            extraConfig = ''
              set -g @continuum-save-interval '5'
              set -g @continuum-restore 'on'
            '';
          }

          # sensible

          {
            # https://github.com/alexwforsythe/tmux-which-key#nix-with-home-manager-flake-installation
            plugin = tmux-which-key;

            extraConfig = ''
              # Enables XDG user directory support for the plugin.
              set -g @tmux-which-key-xdg-enable 1;

              # Disables building the tmux configuration from YAML everytime the plugin starts.
              # The home manager module calls `plugin/build.py` on each generation.
              set -g @tmux-which-key-disable-autobuild 1

              # Follows nixpkgs prefered path for plugins instead of the default
              # path of $XDG_*_HOME/tmux/plugins/tmux-which-key.
              set -g @tmux-which-key-xdg-plugin-path tmux-plugins/tmux-which-key
            '';
          }

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
            exec ${pkgs.tmux}/bin/tmux start-server
          ''}";
          KillMode = "mixed";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

    };

  flake.nixosModules.multiplexer = { pkgs, config, ... }: {

    home-manager.users.${config.preferences.user.name} = {
      imports = [
        self.homeModules.multiplexer
      ];
    };

    nixpkgs.overlays = [
      inputs.tmux-nerd-font-window-name.overlays.default
      # inputs.tmux-which-key.overlays.default
    ];

    environment.systemPackages = with pkgs; [
      inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default
      sesh
      zellij
      tmux
    ];

  };

}
