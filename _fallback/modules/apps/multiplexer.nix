{ inputs, self, ... }: {
  flake.homeModules.multiplexer = { pkgs, ... }: {

    home.packages = [ inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default ];

    # https://workmux.raine.dev/guide/configuration/
    xdg.configFile."workmux/config.yaml".text =
      # yaml
      ''
        merge_strategy: rebase
        nerdfont: true
        merge_keep: true 
        auto_update_check: false

        mode: session
        default_session: default
        window_prefix: "{project}-"

        agent: opencode

        panes:
          - command: clear
            focus: true
      '';

    # [sesh.nix](https://github.com/nix-community/home-manager/blob/master/modules/programs/sesh.nix)
    programs.sesh = {
      enable = true;
      enableAlias = true;

      settings = {
        # Strip Nerdfont prefixes automatically on selection matching
        # Pins raw tmux names out of icon lists securely
        fzf_command = "sesh list --icons | fzf --ansi | awk '{print $2}'";
      };
      # settings = {
      #
      # };
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

          # Prefix key + T
          unbind t
          bind T clock-mode

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
          # bind -N "Split pane horizontally" -n M-S-Enter split-window -h -c "#{pane_current_path}"

          bind C-s display-popup -h 30 -w 100 -E "workmux dashboard -t worktrees"
        '';
      plugins = [
        # https://github.com/joshmedeski/tmux-nerd-font-window-name#nix-flakes
        inputs.tmux-nerd-font-window-name.packages.${pkgs.stdenv.hostPlatform.system}.default
        # TODO: Install later
        # https://github.com/alberti42/tmux-fzf-links
        # https://github.com/jaclu/tmux-menus
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
              set -g @catppuccin_date_time_text "%Y-%m-%d %H:%M:%S"
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
              set -ag status-right "#{E:@catppuccin_status_date_time}"
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
            set -g @resurrect-save 'S'
            set -g @resurrect-restore 'C-r'
          '';
        }

        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-save-interval '5'
            set -g @continuum-restore 'on'

            # set -g @continuum-boot 'on'
            # Prevent continuum from generating its own conflicting systemd file
            # set -g @continuum-systemd-start-cmd 'start-server' 
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
        Description = "Persistent Tmux Server Background Process";
        Documentation = "man:tmux(1)";
      };

      Service = {
        Type = "forking";
        # ExecStart spins up the server socket in the background without opening a terminal window
        # -d spawns it completely detached in the background
        # -s names the session 'default'
        # -c specifies the starting directory ($HOME)
        # ExecStart = "${pkgs.tmux}/bin/tmux new-session -d -s default";
        ExecStart = "${pkgs.tmux}/bin/tmux start-server";
        ExecStop = "${pkgs.tmux}/bin/tmux kill-server";
        Restart = "always";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
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
