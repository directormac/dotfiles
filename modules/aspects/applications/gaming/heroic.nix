# Heroic Games Launcher Aspect
_:
{
  den.aspects.applications.gaming.heroic = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.heroic
        ];
      };
  };
}
