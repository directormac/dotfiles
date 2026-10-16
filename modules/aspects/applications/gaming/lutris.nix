# Lutris Game Manager Aspect
_:
{
  den.aspects.applications.gaming.lutris = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.lutris
        ];
      };
  };
}
