# Starship Prompt Aspect
{
  den.aspects.applications.dev.shell.starship = {

    nixos = {
      programs.starship.enable = true;
    };

    homeManager =
      { config, ... }:
      {
        programs.starship = {
          enable = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;
        };

        xdg.configFile."starship.toml".source = config.lib.dots.link "starship/starship.toml";
      };
  };
}
