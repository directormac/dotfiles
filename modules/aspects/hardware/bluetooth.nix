# Hardware Bluetooth Aspect
{ den, ... }:
{
  den.aspects.hardware.bluetooth = {
    nixos =
      { host, lib, ... }:
      {
        hardware.bluetooth.enable = lib.mkDefault true;
        services.blueman.enable = lib.mkDefault (host.isWorkstation or true);
      };
  };
}
