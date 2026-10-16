# mpvpaper Video Wallpaper Aspect
_:
{
  den.aspects.applications.media.mpvpaper = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.mpvpaper
        ];
      };
  };
}
