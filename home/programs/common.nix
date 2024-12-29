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

  programs.ssh.enable = true;

  services = { udiskie.enable = true; };

}
