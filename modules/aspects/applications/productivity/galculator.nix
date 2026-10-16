# Galculator Calculator Aspect
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
