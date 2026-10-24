# Disk Utilities & Health Monitoring Aspect (GNOME Disks, GSmartControl & GParted)
{
  den.aspects.applications.productivity.disks = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          gnome-disk-utility
          gsmartcontrol
          smartmontools
          gparted
        ];
      };

    homeManager =
      _:
      {
        xdg.desktopEntries = {
          # Dedicated Administrator launcher for GNOME Disks
          gnome-disks-root = {
            settings = {
              StartupNotify = "true";
            };

            categories = [
              "System"
              "Utility"
              "HardwareSettings"
            ];

            comment = "Manage drives, partitions, and media with administrator privileges";
            exec = "pkexec-gui gnome-disks";
            genericName = "Disk Management Utility (Root)";
            icon = "org.gnome.DiskUtility";
            name = "Disks (Administrator)";
            terminal = false;
            type = "Application";
          };

          # GParted partition editor with root elevation
          gparted = {
            settings = {
              StartupNotify = "true";
            };

            categories = [
              "System"
              "Utility"
              "Filesystem"
            ];

            comment = "Create, reorganize, and delete partitions (Administrator)";
            exec = "pkexec-gui gparted";
            genericName = "Partition Editor";
            icon = "gparted";
            name = "GParted";
            terminal = false;
            type = "Application";
          };

          # Elevated GSmartControl for full SMART disk inspection
          gsmartcontrol = {
            settings = {
              StartupNotify = "true";
            };

            categories = [
              "System"
              "Utility"
              "HardwareSettings"
            ];

            comment = "Inspect SMART data and test hard disk and SSD health (Administrator)";
            exec = "pkexec-gui gsmartcontrol";
            genericName = "Hard Disk & SSD Health Inspection";
            icon = "gsmartcontrol";
            name = "GSmartControl";
            terminal = false;
            type = "Application";
          };
        };
      };
  };
}
