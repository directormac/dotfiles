# mpvpaper Video Wallpaper Aspect
{ den, ... }:
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
