# imv Image Viewer Aspect
_:
{
  den.aspects.applications.media.imv = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.imv
        ];
      };
  };
}
