# Lazygit TUI Git Client Aspect
{ core, lib, ... }:
{
  core.lazygit = {
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
        programs.lazygit = {
          enable = true;
        };

        xdg.configFile."lazygit".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/lazygit";
      };

    persistHome.directories = [
      ".local/state/lazygit"
    ];
  };

  den.aspects.artifex.includes = [
    core.lazygit
  ];
}
