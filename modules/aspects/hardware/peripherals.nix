# Hardware Steam & Gamepad Udev Rules Aspect
{
  den.aspects.hardware.steam-hardware = {
    nixos =
      { lib, ... }:
      {
        hardware.steam-hardware.enable = lib.mkDefault true;
        # USB wire or official Xbox Wireless USB Dongle: modern xone driver
        hardware.xone.enable = lib.mkDefault true;
        # Bluetooth: xpadneo fixes the infamous Linux Bluetooth ERTM bug (pairing loops)
        # and enables trigger rumble + correct button mappings
        hardware.xpadneo.enable = lib.mkDefault true;
      };
  };
}
