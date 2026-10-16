# feh Image Viewer Aspect
_:
{
  den.aspects.applications.media.feh = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.feh
        ];

        stylix.targets.feh.enable = true;
      };
  };
}
