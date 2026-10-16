# VLC Media Player & Custom Desktop Actions Leaf Aspect
{
  den.aspects.applications.media.vlc = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.vlc
        ];
      };

    homeManager = {
      xdg.desktopEntries = {
        vlc-enqueue = {
          categories = [
            "AudioVideo"
            "Player"
          ];

          exec = "vlc --one-instance --playlist-enqueue %U";
          genericName = "Media Player (Enqueue)";
          icon = "vlc";

          mimeType = [
            "video/*"
            "audio/*"
          ];

          name = "Add to VLC Playlist";
          terminal = false;
          type = "Application";
        };

        vlc-new-window = {
          categories = [
            "AudioVideo"
            "Player"
          ];

          exec = "vlc --no-one-instance --no-one-instance-when-started-from-file %U";
          genericName = "Media Player (New Window)";
          icon = "vlc";

          mimeType = [
            "video/*"
            "audio/*"
          ];

          name = "Open in New VLC Window";
          terminal = false;
          type = "Application";
        };
      };
    };
  };
}
