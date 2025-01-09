{ pkgs, ... }: {

  imports = [ ../../home/core.nix ../../home/programs ../../home/dots.nix ];

  programs.git = {
    userName = "Mark Asena";
    userEmail = "mac@mkra.dev";
  };

}
