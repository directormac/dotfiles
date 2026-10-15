# Starship Prompt Aspect
{ core, lib, ... }:
{
  core.starship = {
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
        programs.starship = {
          enable = true;
          enableZshIntegration = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
        };

        xdg.configFile."starship.toml".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/starship/starship.toml";
      };
  };

  den.aspects.artifex.includes = [
    core.starship
  ];
}
