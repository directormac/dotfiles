# Terminal Emulators Aspect: Ghostty & Kitty
{
  core,
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs = {
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  core.terminals = {
    homeManager =
      {
        config,
        pkgs,
        user,
        ...
      }:
      let
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
      in
      {
        home.packages = with pkgs; [
          ghostty
          kitty
        ];

        home.file.".config/ghostty".source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/ghostty";

        home.file.".config/kitty".source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/kitty";
      };
  };

  # Attach to workstation aspect
  core.workstation.provides.to-users.includes = [
    core.terminals
  ];
}
