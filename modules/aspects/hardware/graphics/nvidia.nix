# Hardware Graphics NVIDIA Leaf Aspect
_:
{
  den.aspects.hardware.graphics.nvidia = {
    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        # services.prometheus.exporters.nvidia-gpu = {
        #   enable = true;
        #   listenAddress = "127.0.0.1";
        # };
        boot = {
          extraModprobeConfig =
            "options nvidia "
            + lib.concatStringsSep " " [
              "NVreg_UsePageAttributeTable=1"
              "nvidia.NVreg_EnableGpuFirmware=1"
              "NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100"
            ];

          kernelModules = [
            "nvidia"
            "nvidia_modeset"
            "nvidia_drm"
            "nvidia_uvm"
          ];

          kernelParams = [
            "nvidia-drm.modeset=1"
            "nvidia-drm.fbdev=1"
          ];
        };

        environment = {
          systemPackages = [
            pkgs.lact
            pkgs.pciutils
            pkgs.nvtopPackages.full
            pkgs.libva-utils
            pkgs.gwe
            pkgs.vulkan-tools
            pkgs.mesa-demos
            pkgs.zenith-nvidia
            pkgs.nvitop
            pkgs.btop-cuda
            pkgs.vulkan-loader
            pkgs.vulkan-validation-layers
          ];

          variables = {
            CUDA_PATH = "${pkgs.cudatoolkit}";
          };
        };

        hardware.graphics = {
          enable = true;

          extraPackages = [
            pkgs.libva-vdpau-driver
            pkgs.libvdpau
            pkgs.libvdpau-va-gl
            pkgs.nvidia-vaapi-driver
            pkgs.vdpauinfo
            pkgs.libva
            pkgs.libva-utils
          ];
        };

        hardware.nvidia = {
          forceFullCompositionPipeline = false;
          modesetting.enable = true;
          nvidiaPersistenced = lib.mkDefault false;
          nvidiaSettings = false;
          open = true;

          # nix-cachyos-kernel de-consts __to_hwgpio() with --replace-fail;
          # nvidia-open >=615 already ships it de-consted, so that substitution
          # aborts the build. Downgrade it to a warning.
          package =
            let
              base = config.boot.kernelPackages.nvidiaPackages.latest;
            in
            base.overrideAttrs (_: {
              passthru = base.passthru // {
                open = base.open.overrideAttrs (o: {
                  postPatch = builtins.replaceStrings [ "--replace-fail" ] [ "--replace-warn" ] (o.postPatch or "");
                });
              };
            });

          powerManagement.enable = true;
        };

        nixpkgs.config = {
          nvidia.acceptLicense = true;
          # cudaSupport = true; # TODO: Enable CUDA
          # cudnnSupport = true;
        };

        services.xserver.videoDrivers = [ "nvidia" ];
      };

    # GPU utilisation, memory, temperature, power (nvidia-smi), shipped by the
    # host's Alloy when it runs one.
    prometheus-targets =
      { environment, host, ... }:
      {
        inherit environment;

        exporters = [
          {
            job = "nvidia-gpu";
            port = 9835;
          }
        ];

        hostname = host.name;
        ip = builtins.head host.ipv4;
      };
  };
}
