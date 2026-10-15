# Hardware Input (libinput & uinput) Aspect
{ den, ... }:
{
  den.aspects.hardware.input = {
    nixos =
      { lib, pkgs, ... }:
      {
        hardware.uinput.enable = lib.mkDefault true;
        services.libinput.enable = lib.mkDefault true;

        environment.systemPackages = [
          pkgs.libinput
        ];
      };
  };
}
