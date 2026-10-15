# Lutris Game Manager Aspect
{ den, ... }:
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
