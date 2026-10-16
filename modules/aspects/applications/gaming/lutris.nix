# Lutris Game Manager Aspect
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
