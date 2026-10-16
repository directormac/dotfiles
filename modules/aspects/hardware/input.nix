# Hardware Input (libinput & uinput) Aspect
{
  den.aspects.hardware.input = {
    nixos =
      { lib, pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.libinput
        ];

        hardware.uinput.enable = lib.mkDefault true;
        services.libinput.enable = lib.mkDefault true;
      };
  };
}
