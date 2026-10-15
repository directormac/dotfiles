# Tmux Aspect with Out-of-Store Config Symlinks
{ core, ... }:
{
  core.tmux = {
    homeManager =
      {
        config,
        user,
        ...
      }:
      let
        dotfilesTmux = "${dotsPath}/tmux";
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
      in
      {
        programs.tmux = {
          baseIndex = 1;
          clock24 = true;
          enable = true;
          escapeTime = 100;

          extraConfig = ''
            set -g status-interval 1
            set -g repeat-time 350
            set -g display-time 1500
            set -s set-clipboard on
            set -g renumber-windows on
            set -g detach-on-destroy off
            set -g wrap-search off
            set -g allow-passthrough all
          '';

          historyLimit = 100000;
          keyMode = "vi";
          mouse = true;
          prefix = "C-a";
          shortcut = "a";
          terminal = "tmux-256color";
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

    persistHome.directories = [
      ".local/share/tmux"
    ];
  };

  den.aspects.artifex.includes = [
    core.tmux
  ];
}
