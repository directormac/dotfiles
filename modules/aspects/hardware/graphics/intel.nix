# Hardware Graphics Intel Leaf Aspect
{ den, ... }:
{
  den.aspects.hardware.graphics.intel = {
    nixos =
      { pkgs, ... }:
      {
        services.xserver.videoDrivers = [ "modesetting" ];

        hardware.graphics = {
          enable = true;
          extraPackages = [
            pkgs.intel-media-driver
            pkgs.intel-ocl
            pkgs.vpl-gpu-rt
            pkgs.intel-compute-runtime
            pkgs.intel-vaapi-driver
            pkgs.libvdpau-va-gl
          ];
        };

        boot.kernelParams = [
          "i915.enable_guc=3"
        ];

        environment.sessionVariables = {
          VDPAU_DRIVER = "va_gl";
          LIBVA_DRIVER_NAME = "iHD";
        };

        environment.systemPackages = [
          pkgs.pciutils
          pkgs.intel-gpu-tools
          pkgs.nvtopPackages.intel
          pkgs.mesa-demos
          pkgs.vulkan-loader
          pkgs.vulkan-validation-layers
          pkgs.vulkan-tools
          pkgs.libva-utils
        ];
      };
  };
}
