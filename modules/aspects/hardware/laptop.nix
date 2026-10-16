# Hardware Laptop Leaf Aspect
{
  den.aspects.hardware.laptop = {
    nixos =
      { lib, pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          brightnessctl
        ];

        services.power-profiles-daemon.enable = lib.mkDefault true;
        services.upower.enable = lib.mkDefault true;
      };
  };
}
