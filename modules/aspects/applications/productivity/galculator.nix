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

    cacheHome.directories = [
      ".local/share/qalculate"
    ];

    persistHome.directories = [
      ".config/galculator"
    ];
  };
}
