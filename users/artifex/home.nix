{ pkgs, ... }: {

  imports = [ ../../home/core.nix ../../home/programs.nix ];

  programs.git = {
    userName = "Mark Asena";
    userEmail = "mac@mkra.dev";
  };

}
