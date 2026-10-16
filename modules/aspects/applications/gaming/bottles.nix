# Bottles Wine Prefix Manager Aspect
{
  den.aspects.applications.gaming.bottles = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          (pkgs.bottles.override { removeWarningPopup = true; })
        ];
      };
  };
}
