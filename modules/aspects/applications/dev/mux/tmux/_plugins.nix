# Tmux Plugins
#
# Holds the `programs.tmux.plugins` list. Every plugin is configured through
# its own `extraConfig` block, tagged with the `# tmux` comment so that
# Neovim resolves the injection to the tmux grammar instead of shell
# (see `_config.nix` for details).
#
# `resurrect` is wired through the plugin's own scripts and bindings:
#   * `resurrect` provides the `C-S` / `C-R` save and restore bindings and
#     its own `save.sh` / `restore.sh` scripts.
#   * `continuum` periodically calls resurrect's `save.sh` and restores the
#     last session on boot. It is loaded from `_config.nix` instead of from
#     here, because Home Manager emits the plugin blocks *before* `extraConfig`
#     while `run-shell` blocks the configuration until the command returns.
#     Loading it from a plugin block would run it before `status.tmux.conf` is
#     sourced and would restore the last session twice.
{
  pkgs,
  inputs,
  resurrectDir,
  windowIcon,
  windowNumber,
  ...
}:
let
  tmuxFzfLinks = pkgs.tmuxPlugins.mkTmuxPlugin {
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

  tmuxMenus = pkgs.tmuxPlugins.mkTmuxPlugin {
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
in
{
  plugins = [
    {
      extraConfig =
        # tmux
        ''
          set -g @tmux-nerd-font-window-name-config-file "$HOME/.config/tmux/tmux-nerd-font-window-name.yml"
          set -g automatic-rename-format "#{window_icon}"
        '';

      plugin = pkgs.tmuxPlugins.tmux-nerd-font-window-name;
    }
    {
      extraConfig =
        # tmux
        ''
          set -g @fzf-links-key "u"
          set -g @fzf-links-python "${pkgs.python3}/bin/python3"
          set -g @fzf-links-browser-open-cmd "zen-beta '%url'"
          set -g @fzf-links-editor-open-cmd "tmux new-window -n 'nvim' nvim +%line '%file'"
        '';

      plugin = tmuxFzfLinks;
    }
    {
      extraConfig =
        # tmux
        ''
          set -g @menus_use_cache "No"
          set -g @menus_trigger '\'
        '';

      plugin = tmuxMenus;
    }
  ]
  ++ (with pkgs.tmuxPlugins; [
    {
      extraConfig =
        # tmux
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

          set -g @catppuccin_window_text "#{?window_bell_flag,#[fg=#{@thm_crust} bg=#{@thm_maroon} bold] #{?client_prefix,${windowNumber} ,} ${windowIcon} #[default],#[fg=#{@thm_mauve} bg=default] #{?client_prefix,${windowNumber} ,}${windowIcon} }"
          set -g @catppuccin_window_current_number ""
          set -g @catppuccin_window_current_text "#{?window_bell_flag,#[fg=#{@thm_crust} bg=#{@thm_maroon} bold]  ${windowIcon} #[default],#[fg=#{@thm_crust} bg=#{@thm_blue} bold] #{?client_prefix,${windowNumber} ,}${windowIcon} }"
        '';

      plugin = catppuccin;
    }
    {
      extraConfig =
        # tmux
        ''
          set -g @resurrect-strategy-vim "session"
          set -g @resurrect-strategy-nvim "session"
          set -g @resurrect-processes "lazydocker lazygit yazi"

          # The snapshots live in the persisted tmux state directory, so they
          # survive a reboot and continuum/ExecStartPost can restore the last session.
          set -g @resurrect-dir "${resurrectDir}"

          # Strip the volatile Nix store paths from recorded pane commands before
          # `save.sh` compares the new dump against `last` with `files_differ`.
          set -g @resurrect-hook-post-save-layout "sed -i 's| --cmd .*-vim-pack-dir||g; s| --cmd source/nix/store/[^ ]*||g; s|/etc/profiles/per-user/$USER/bin/||g; s|/nix/store/.*/bin/||g'"

          set -g @resurrect-save "C-S"
          set -g @resurrect-restore "C-R"
        '';

      plugin = resurrect;
    }
  ]);
}
