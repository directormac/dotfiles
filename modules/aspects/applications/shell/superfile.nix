# Superfile Terminal File Manager Leaf Aspect
_:
{
  den.aspects.applications.shell.superfile = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.superfile
        ];
      };

    homeManager =
      { lib, host, ... }:
      {
        programs.superfile = {
          enable = true;
        };

        xdg.desktopEntries = lib.mkIf (host.isWorkstation or true) {
          superfile = {
            actions = {
              "open-in-superfile" = {
                exec = "ghostty --class=com.superfile.fm -e superfile %f";
                name = "Open in Superfile";
              };
            };

            categories = [
              "System"
              "FileManager"
              "Utility"
              "Core"
            ];

            exec = "ghostty --class=com.superfile.fm -e superfile %F";
            genericName = "Terminal File Manager";
            icon = "utilities-terminal";
            mimeType = [ "inode/directory" ];
            name = "Superfile";
            terminal = false;
            type = "Application";
          };
        };
      };
  };
}
