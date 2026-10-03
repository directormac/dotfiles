{
  flake.homeModules.mpv = { pkgs, ... }: {
    stylix.targets.mpv.enable = true;
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

      package = (
        pkgs.mpv.override {
          scripts = with pkgs.mpvScripts; [
            autoload
            autosub
            modernx-zydezu
            # mpris
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
        }
      );
    };
  };
}
