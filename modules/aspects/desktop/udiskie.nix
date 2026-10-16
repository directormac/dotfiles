# Desktop Removable Media & GVFS / Udiskie Automount Leaf Aspect
_:
{
  den.aspects.desktop.udiskie = {
    nixos =
      { lib, pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          udiskie
          udisks2
        ];

        programs.fuse.userAllowOther = true;

        services = {
          dbus.enable = lib.mkDefault true;
          gvfs.enable = lib.mkDefault true;
          tumbler.enable = lib.mkDefault true;
          udisks2.enable = lib.mkDefault true;
        };
      };

    homeManager = _: {
      services.udiskie = {
        settings = {
          device_config = [
            {
              options = {
                detach = true;
                eject = true;
              };

              match = {
                device_file = "/dev/loop*";
              };
            }
          ];

          icon_names = {
            media = [
              "drive-removable-media-usb"
              "drive-removable-media"
              "media-flash"
              "media-optical"
            ];
          };

          program_options = {
            automount = true;
            notify = true;
            tray = "auto";
            udisks_version = 2;
          };
        };

        enable = true;
      };
    };
  };
}
