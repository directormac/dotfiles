# Superfile Terminal File Manager Leaf Aspect
{ den, ... }:
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
      { host, lib, ... }:
      {
        programs.superfile = {
          enable = true;
        };

        xdg.desktopEntries = lib.mkIf (host.isWorkstation or true) {
          superfile = {
            name = "Superfile";
            genericName = "Terminal File Manager";
            exec = "ghostty --class=com.superfile.fm -e superfile %F";
            terminal = false;
            type = "Application";
            icon = "utilities-terminal";
            mimeType = [ "inode/directory" ];
            categories = [
              "System"
              "FileManager"
              "Utility"
              "Core"
            ];
            actions = {
              "open-in-superfile" = {
                name = "Open in Superfile";
                exec = "ghostty --class=com.superfile.fm -e superfile %f";
              };
            };
          };
        };
      };
  };
}
