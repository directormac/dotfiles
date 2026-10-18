# Hardware Bluetooth Aspect
{
  den.aspects.hardware.bluetooth = {
    nixos =
      { lib, host, ... }:
      {
        hardware.bluetooth.enable = lib.mkDefault true;
        services.blueman.enable = lib.mkDefault (host.isWorkstation or true);
      };

    persist.directories = [
      "/var/lib/bluetooth"
    ];
  };
}
