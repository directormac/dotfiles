# MPV Media Player Leaf Aspect
{ den, ... }:
{
  den.aspects.applications.media.mpv = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          ffmpeg-full
          mpv
        ];
      };

    homeManager =
      { lib, pkgs, ... }:
      {
        home.packages = [
          pkgs.mpvc
        ];

        stylix.targets.mpv.enable = lib.mkDefault true;

        programs.mpv = {
          enable = true;
          config = {
            profile = "high-quality";
            ytdl-format = "bestvideo+bestaudio";
            cache = "yes";
            demuxer-max-bytes = "400M";
            osc = false;
            border = false;
          };
          package = pkgs.mpv.override {
            scripts = with pkgs.mpvScripts; [
              autoload
              autosub
              modernx-zydezu
              mpv-playlistmanager
              quality-menu
              sponsorblock
              thumbfast
              videoclip
              webtorrent-mpv-hook
              youtube-upnext
            ];
            mpv-unwrapped = pkgs.mpv-unwrapped.override {
              waylandSupport = true;
              ffmpeg = pkgs.ffmpeg-full;
            };
          };
        };
      };

    persistHome.directories = [
      ".config/mpv"
    ];
  };
}
