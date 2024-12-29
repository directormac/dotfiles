{ pkgs, ... }: {

  imports = [ ../../home/core.nix ../../home/programs ];

  users.defaultUserShell = pkgs.zsh;

  programs.git = {
    userName = "Mark Asena";
    userEmail = "mac@mkra.dev";
  };

}
