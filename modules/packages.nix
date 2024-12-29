{ config, pkgs, inputs, ... }:

{
  environment.pathsToLink = [ "/libexec" ];
  
  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    git
    neovim
    aria2
    xdg-user-dirs
    xdg-utils
    stow
    inputs.wezterm.packages.${pkgs.system}.default
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
