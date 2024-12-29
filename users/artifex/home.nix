{ pkgs, ... }: {

  imports = [ ../../home/core.nix ../../home/programs ];

  programs.git = {
    userName = "Mark Asena";
    userEmail = "mac@mkra.dev";
  };

}
