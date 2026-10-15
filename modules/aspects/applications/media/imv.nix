# imv Image Viewer Aspect
{ den, ... }:
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
