# Service Smartd Disk Health Monitoring Aspect
{
  den.aspects.services.smartd = {
    homeManager =
      {
        lib,
        pkgs,
        host,
        ...
      }:
      lib.mkIf (host.isWorkstation or true) {
        home.packages = [
          pkgs.gsmartcontrol
        ];

        xdg.desktopEntries.gsmartcontrol = {
          categories = [
            "System"
            "Utility"
          ];

          exec = "gsmartcontrol";
          icon = "gsmartcontrol";
          name = "GSmartControl";
          terminal = false;
          type = "Application";
        };
      };

    nixos =
      {
        lib,
        pkgs,
        ...
      }:
      {
        environment.systemPackages = with pkgs; [
          smartmontools
          gnome-disk-utility
        ];

        services.smartd = {
          enable = lib.mkDefault true;
          autodetect = true;
        };
      };
  };
}
