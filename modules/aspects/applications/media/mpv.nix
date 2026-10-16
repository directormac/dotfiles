# MPV Media Player Leaf Aspect
_:
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

        programs.mpv = {
          config = {
            border = false;
            cache = "yes";
            demuxer-max-bytes = "400M";
            osc = false;
            profile = "high-quality";
            ytdl-format = "bestvideo+bestaudio";
          };

          enable = true;

          package = pkgs.mpv.override {
            mpv-unwrapped = pkgs.mpv-unwrapped.override {
              ffmpeg = pkgs.ffmpeg-full;
              waylandSupport = true;
            };

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
          };
        };

        stylix.targets.mpv.enable = lib.mkDefault true;
      };

    persistHome.directories = [
      ".config/mpv"
    ];
  };
}
