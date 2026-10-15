# Heroic Games Launcher Aspect
{ den, ... }:
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
