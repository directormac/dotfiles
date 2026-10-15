# Hardware Steam & Gamepad Udev Rules Aspect
{ den, ... }:
{
  den.aspects.hardware.steam-hardware = {
    nixos =
      { lib, ... }:
      {
        hardware.steam-hardware.enable = lib.mkDefault true;
      };
  };

  den.aspects.hardware.gamepad.includes = [ den.aspects.hardware.steam-hardware ];
}
