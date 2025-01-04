{ lib, pkgs, ... }: {

  home.packages = with pkgs; [
    #Legacy
    htop
    aria2
    less

    # Archives
    p7zip
    unzip
    zip

    # Utilities
    bat
    btop
    dust
    fd
    fzf
    fzf-git-sh
    jq
    lazydocker
    lazygit
    lsd
    moar
    navi
    navi
    ripgrep
    starship
    ueberzugpp
    yazi
    yq
    zoxide

    # Misc
    libnotify
    mycli
    pgcli
    redis

  ];

  programs.ssh.enable = true;

  services = { udiskie.enable = true; };

}
