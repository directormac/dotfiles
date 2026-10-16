# yt-dlp Video Downloader Leaf Aspect
_:
{
  den.aspects.applications.media.yt-dlp = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.yt-dlp
        ];
      };
  };
}
