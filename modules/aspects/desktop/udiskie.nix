# Desktop Removable Media & GVFS / Udiskie Automount Leaf Aspect
{ den, ... }:
{
  den.aspects.desktop.udiskie = {
    nixos =
      { lib, pkgs, ... }:
      {
        services = {
          dbus.enable = lib.mkDefault true;
          gvfs.enable = lib.mkDefault true;
          tumbler.enable = lib.mkDefault true;
          udisks2.enable = lib.mkDefault true;
        };

        programs.fuse.userAllowOther = true;

        environment.systemPackages = with pkgs; [
          udiskie
          udisks2
        ];
      };

    homeManager =
      _:
      {
        services.udiskie = {
          enable = true;
          settings = {
            icon_names = {
              media = [
                "drive-removable-media-usb"
                "drive-removable-media"
                "media-flash"
                "media-optical"
              ];
            };
            program_options = {
              tray = "auto";
              automount = true;
              notify = true;
              udisks_version = 2;
            };
            device_config = [
              {
                match = {
                  device_file = "/dev/loop*";
                };
                options = {
                  detach = true;
                  eject = true;
                };
              }
            ];
          };
        };
      };
  };
}
