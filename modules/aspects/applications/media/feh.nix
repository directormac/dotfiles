# feh Image Viewer Aspect
{ den, ... }:
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
