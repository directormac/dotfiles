# Hardware Power Management & Trim (tuned, upower, fstrim) Aspect
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
