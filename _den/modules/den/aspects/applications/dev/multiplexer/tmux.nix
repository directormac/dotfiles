{
  den.aspects.applications.dev.multiplexer.tmux = {
    homeManager = {pkgs, ...}: {
      programs.tmux = {
        enable = true;
        sensibleOnTop = true;
        terminal = "tmux-256color";
        shortcut = "a";
        keyMode = "vi";
        customPaneNavigationAndResize = true;
        baseIndex = 1;
        plugins = with pkgs.tmuxPlugins; [
          extrakto
          cpu
          weather
          battery
          vim-tmux-navigator
          tmux-window-name
        ];
        extraConfig = ''
          set -ga terminal-overrides ",*:Tc"
        '';
      };
    };
  };
}
