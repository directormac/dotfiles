{ lib, pkgs, ... }: {

  home.packages = with pkgs; [
    #Legacy
    htop
    aria2

    # Archives
    zip
    unzip
    p7zip

    # Utilities
    ripgrep
    fzf
    jq
    fd
    bat
    btop
    lsd
    navi
    zoxide
    fzf-git-sh
    yazi
    ueberzugpp
    lazygit
    starship

    # Misc
    libnotify
    xdg-utils

    # DB Related
    mycli
    pgcli

  ];

  programs = {

    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      baseIndex = 1;
      terminal = "tmux-256color";

      extraConfig = ''
        set -g default-terminal "tmux-256color"
        set -ag terminal-overrides ",*:Tc"
        set-environment -g COLORTERM "truecolor"
      '';
    };

    ssh.enable = true;

  };

  services = { udiskie.enable = true; };

}
