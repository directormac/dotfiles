# Hardware Laptop Leaf Aspect
{ den, ... }:
{
  den.aspects.hardware.laptop = {
    nixos =
      { lib, pkgs, ... }:
      {
        services.power-profiles-daemon.enable = lib.mkDefault true;
        services.upower.enable = lib.mkDefault true;

        environment.systemPackages = with pkgs; [
          brightnessctl
        ];
      };
  };
}
