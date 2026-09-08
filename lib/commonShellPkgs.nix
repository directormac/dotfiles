{ ... }: {
  flake = {
    commonShellPkgs = pkgs: self': with pkgs; [
      lsd
      dust
      btop
      ripgrep
      fd
      vivid
      zoxide
      bat
      yazi
      self'.packages.lazygit
    ];
  };
}
