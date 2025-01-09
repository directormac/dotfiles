{ pkgs, ... }:
# let

  # tmux-nerd-font-window-name = pkgs.tmuxPlugins.mkTmuxPlugin {
  #   pluginName = tmux-nerd-font-window-name;
  #   src = pkgs.fetchFromGitHub {
  #     src = pkgs.fetchFromGitHub {
  #       owner = "joshmedeski";
  #       repo = "tmux-nerd-font-window-name";
  #       rev = "master"; # Or specific commit hash
  #       sha256 =
  #         "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with actual hash
  #     };
  #   };
  # };
  #
  # tmux-which-key = pkgs.tmuxPlugins.mkTmuxPlugin {
  #   pluginName = tmux-which-key;
  #   src = pkgs.fetchFromGitHub {
  #     owner = "lexwforsythe";
  #     repo = "tmux-which-key";
  #     rev = "master"; # Or specific commit hash
  #     sha256 =
  #       "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with actual hash
  #   };
  # };
  #
  # tmux-session-wizard = pkgs.tmuxPlugins.mkTmuxPlugin {
  #   pluginName = tmux-session-wizard;
  #   src = pkgs.fetchFromGitHub {
  #     owner = "27medkamal";
  #     repo = "tmux-session-wizard";
  #     rev = "master";
  #     sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
  #   };
  # };

# in 
  {

  home.file.".tmux.conf".source = ./tmux.conf;

  programs = {

    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      baseIndex = 1;
      terminal = "tmux-256color";
      shell = "${pkgs.zsh}/bin/zsh";

      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = catppuccin;
          extraConfig = ''

            set -g @catppuccin_flavor 'mocha' # latte,frappe, macchiato or mocha
            set -g @catppuccin_window_status_style "basic"
            set -g @catppuccin_status_left_separator "█"
            set -g @catppuccin_status_right_separator "█"
            set -g @catppuccin_date_time_text "%Y-%m-%d %H:%M:%S"
            set -g @catppuccin_status_background "none"

            ### Plugin: https://github.com/catppuccin/tmux
            set-option -g @catppuccin_window_number_position 'left'
            set-option -g @catppuccin_window_flags 'no'
            set-option -g @catppuccin_window_text ' #W'
            set-option -g @catppuccin_window_current_text ' #W'


            set -g status-left ""
            set -g status-right-length 100
            set -g status-right "#{E:@catppuccin_status_directory}"
            # set -ag status-right "#{E:@catppuccin_status_user}"
            set -ag status-right "#{E:@catppuccin_status_session}"
            set -ag status-right "#{E:@catppuccin_status_date_time}"

          '';
        }

        sensible
        resurrect
        open
        pain-control
        fzf-tmux-url

        # { plugin = tmux-nerd-font-window-name; }
        # { plugin = tmux-which-key; }
        #
        # {
        #   plugin = tmux-session-wizard;
        #   extraConfig = ''
        #     set -g @session-wizard 't'
        #   '';
        # }

        {
          plugin = resurrect;
          extraConfig = ''
            set -g @resurrect-strategy-vim 'session'
            set -g @resurrect-strategy-nvim 'session'
            set -g @resurrect-capture-pane-contents 'on'
          '' + ''
            # Taken from: https://github.com/p3t33/nixos_flake/blob/5a989e5af403b4efe296be6f39ffe6d5d440d6d6/home/modules/tmux.nix
            resurrect_dir="$XDG_CACHE_HOME/.tmux/resurrect"
            set -g @resurrect-dir $resurrect_dir

            set -g @resurrect-hook-post-save-all 'target=$(readlink -f $resurrect_dir/last); sed "s| --cmd .*-vim-pack-dir||g; s|/etc/profiles/per-user/$USER/bin/||g; s|/home/$USER/.nix-profile/bin/||g" $target | sponge $target'
          '';
        }

        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-boot 'on'
            set -g @continuum-save-interval '10'
            set -g @continuum-systemd-start-cmd 'start-server'
          '';
        }
      ];

      extraConfig = "\n";
    };
  };
}

