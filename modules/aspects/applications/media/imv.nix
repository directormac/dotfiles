# imv Image Viewer Aspect
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
