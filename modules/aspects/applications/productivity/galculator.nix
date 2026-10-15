# Galculator Calculator Aspect
{ den, ... }:
{
  den.aspects.applications.productivity.galculator = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.galculator
        ];
      };
  };
}
