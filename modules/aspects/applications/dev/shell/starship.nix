# Starship Prompt Aspect
{
  den.aspects.applications.dev.shell.starship = {
    homeManager =
      {
        config,
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
}
