# Heroic Games Launcher Aspect
{
  den.aspects.applications.gaming.heroic = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.heroic
        ];
      };

    persistHome.directories = [
      ".config/heroic"
    ];
  };
}
