# Service Smartd Disk Health Monitoring Aspect
{ den, ... }:
{
  den.aspects.services.smartd = {
    nixos =
      {
        host,
        lib,
        pkgs,
        ...
      }:
      {
        services.smartd = {
          autodetect = true;
          enable = lib.mkDefault true;
        };

        environment.systemPackages = with pkgs; [
          smartmontools
          gnome-disk-utility
        ];
      };

    homeManager =
      {
        host,
        lib,
        pkgs,
        ...
      }:
      lib.mkIf (host.isWorkstation or true) {
        home.packages = [
          pkgs.gsmartcontrol
        ];

        xdg.desktopEntries.gsmartcontrol = {
          name = "GSmartControl";
          exec = "gsmartcontrol";
          icon = "gsmartcontrol";
          terminal = false;
          categories = [
            "System"
            "Utility"
          ];
          type = "Application";
        };
      };
  };
}
