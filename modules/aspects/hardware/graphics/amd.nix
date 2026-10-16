# Hardware Graphics AMD Leaf Aspect
{
  den.aspects.hardware.graphics.amd = {
    nixos =
      { pkgs, ... }:
      {
        boot.kernelModules = [
          "amdgpu"
        ];

        boot.kernelParams = [
          "amdgpu.dc=1"
          "amdgpu.powerplay=1"
          "radeon.modeset=0"
        ];

        # nixpkgs.config.rocmSupport = true; # TODO: Restore ROCM
        environment.systemPackages = [
          pkgs.lact
          pkgs.pciutils
          pkgs.rocmPackages.rocminfo
          pkgs.clinfo
          pkgs.nvtopPackages.amd
          pkgs.amdgpu_top
          pkgs.vulkan-tools
          pkgs.vulkan-loader
          pkgs.vulkan-validation-layers
          pkgs.vulkan-extension-layer
          pkgs.libva-utils
          pkgs.mesa-demos
        ];

        hardware = {
          amdgpu = {
            initrd.enable = true;
            opencl.enable = true;

            overdrive = {
              enable = true;
              ppfeaturemask = "0xffffffff";
            };
          };

          graphics = {
            enable = true;
            enable32Bit = true;

            extraPackages = [
              pkgs.libva-vdpau-driver
              pkgs.libva
              pkgs.libvdpau-va-gl
              pkgs.rocmPackages.clr.icd
            ];
          };
        };

        services.xserver.videoDrivers = [ "amdgpu" ];
        # GPU overclocking/undervolting daemon
        systemd.packages = [ pkgs.lact ];
        systemd.services.lactd.wantedBy = [ "multi-user.target" ];
      };
  };
}
