# Hardware Graphics & GPU Acceleration Aspect
{
  den.aspects.hardware.graphics = {
    nixos =
      { lib, pkgs, ... }:
      {
        hardware.graphics = {
          enable = lib.mkDefault true;
          enable32Bit = lib.mkDefault true;

          extraPackages = with pkgs; [
            intel-media-driver
            vpl-gpu-rt
          ];
        };

        services.xserver.videoDrivers = lib.mkDefault [
          "amdgpu"
          "modesetting"
        ];

        environment.systemPackages = with pkgs; [
          clinfo
          libva-utils
          vulkan-tools
        ];
      };
  };
}
