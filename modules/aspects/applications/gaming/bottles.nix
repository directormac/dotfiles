# Bottles Wine Prefix Manager Aspect
_:
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
