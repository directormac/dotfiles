{ ... }: {

  # This is your configuration.nix, a place where you configure your system
  # You can place it in a separate file.
  flake.nixosModules.nixosModule = {

    # Install firefox.
    # programs.firefox.enable = true;

    # https://nixos.wiki/wiki/Vim
    # programs.vim = {
    # enable = true;
    # defaultEditor = true;
    # package = pkgs.vim-full;
    # };

  };
}
