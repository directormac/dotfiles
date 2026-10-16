# Galculator Calculator Aspect
_:
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
