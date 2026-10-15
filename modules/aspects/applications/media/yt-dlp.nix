# yt-dlp Video Downloader Leaf Aspect
{ den, ... }:
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
