# Hardware Steam & Gamepad Udev Rules Aspect
_:
{
  den.aspects.hardware.steam-hardware = {
    nixos =
      { lib, ... }:
      {
        hardware.steam-hardware.enable = lib.mkDefault true;
      };
  };
}
