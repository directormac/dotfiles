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

        # agent: claude
        # panes:
        #   - command: <agent>
        #     focus: true
        #   - split: horizontal
      '';

    # [sesh.nix](https://github.com/nix-community/home-manager/blob/master/modules/programs/sesh.nix)
    programs.sesh = {
      enable = true;
      enableAlias = true;
      settings = {

      };
    };

    programs.tmux = {
      enable = true;
      prefix = "C-a";
      clock24 = true;
      baseIndex = 1;
      keyMode = "vi";
      newSession = true;
      mouse = true;
      historyLimit = 1000000;

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

          # Tell tmux that the *outside* terminal (Ghostty/Alacritty/etc.) supports True Color (RGB)
          # This works for Ghostty (which uses xterm-ghostty) and others using xterm-256color
          set -as terminal-features ",xterm-ghostty:RGB"
          set -as terminal-features ",xterm-256color:RGB"
        '';
      plugins = [
        # https://github.com/joshmedeski/tmux-nerd-font-window-name#nix-flakes
        inputs.tmux-nerd-font-window-name.packages.${pkgs.stdenv.hostPlatform.system}.default
        # TODO: Install later
        # https://github.com/alberti42/tmux-fzf-links
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

        sensible

        tmux-which-key
      ]);
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
    ];

    environment.systemPackages = with pkgs; [
      inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default
      sesh
      zellij
      tmux
    ];

  };

}
