# Hardware Power Management & Trim (tuned, upower, fstrim) Aspect
_:
{
  den.aspects.hardware.power = {
    nixos =
      { lib, ... }:
      {
        services = {
          fstrim.enable = lib.mkDefault true;
          tuned.enable = lib.mkDefault true;
          upower.enable = lib.mkDefault true;
        };
      };
  };
}
