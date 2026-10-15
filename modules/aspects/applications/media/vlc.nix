# VLC Media Player & Custom Desktop Actions Leaf Aspect
{ den, ... }:
{
  den.aspects.applications.media.vlc = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.vlc
        ];
      };

    homeManager =
      _:
      {
        xdg.desktopEntries = {
          vlc-new-window = {
            name = "Open in New VLC Window";
            genericName = "Media Player (New Window)";
            exec = "vlc --no-one-instance --no-one-instance-when-started-from-file %U";
            icon = "vlc";
            terminal = false;
            type = "Application";
            categories = [
              "AudioVideo"
              "Player"
            ];
            mimeType = [
              "video/*"
              "audio/*"
            ];
          };

          vlc-enqueue = {
            name = "Add to VLC Playlist";
            genericName = "Media Player (Enqueue)";
            exec = "vlc --one-instance --playlist-enqueue %U";
            icon = "vlc";
            terminal = false;
            type = "Application";
            categories = [
              "AudioVideo"
              "Player"
            ];
            mimeType = [
              "video/*"
              "audio/*"
            ];
          };
        };
      };
  };
}
