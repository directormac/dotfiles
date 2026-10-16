# Hardware Graphics NVIDIA VFIO Passthrough Leaf Aspect
{ den, ... }:
{
  den.aspects.hardware.graphics.nvidia-vfio = {
    includes = with den.aspects; [
      virtualization.libvirt
    ];

    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        facterCards = lib.attrByPath [ "facter" "report" "hardware" "graphics_card" ] [ ] config;
        facterSounds = lib.attrByPath [ "facter" "report" "hardware" "sound" ] [ ] config;
        nvidiaAudioController = lib.lists.findFirst (
          card:
          (card ? vendor && card.vendor ? name && card.vendor.name == "nVidia Corporation")
          || (card ? vendor && card.vendor ? hex && card.vendor.hex == "10de")
        ) null facterSounds;
        nvidiaAudioDeviceID =
          if
            nvidiaAudioController != null && nvidiaAudioController ? vendor && nvidiaAudioController ? device
          then
            "${nvidiaAudioController.vendor.hex}:${nvidiaAudioController.device.hex}"
          else
            "10de:1aef";
        nvidiaCard = lib.lists.findFirst (
          card:
          (card ? vendor && card.vendor ? name && card.vendor.name == "nVidia Corporation")
          || (card ? vendor && card.vendor ? hex && card.vendor.hex == "10de")
        ) null facterCards;
        nvidiaGpuDeviceID =
          if nvidiaCard != null && nvidiaCard ? vendor && nvidiaCard ? device then
            "${nvidiaCard.vendor.hex}:${nvidiaCard.device.hex}"
          else
            "10de:2203";
      in
      {
        boot = {
          blacklistedKernelModules = [
            "nvidia"
            "nvidia_modeset"
            "nvidia_uvm"
            "nvidia_drm"
            "i2c_nvidia_gpu"
            "nvidia-gpu"
            "nouveau"
          ];

          extraModprobeConfig = ''
            options vfio-pci ids=${nvidiaGpuDeviceID},${nvidiaAudioDeviceID}
            options kvmfr static_size_mb=256
            options kvm_amd nested=1 avic=1 npt=1 sev=0
            options kvm_intel nested=1
            options vfio_iommu_type1 allow_unsafe_interrupts=1
            blacklist nouveau
            options nouveau modeset=0
          '';

          extraModulePackages = [
            config.boot.kernelPackages.kvmfr
          ];

          initrd.kernelModules = [
            "vfio_pci"
            "vfio"
            "vfio_iommu_type1"
            "kvmfr"
          ];

          kernelParams = [
            "vfio-pci.ids=${nvidiaGpuDeviceID},${nvidiaAudioDeviceID}"
            "vfio_iommu_type1.allow_unsafe_interrupts=1"
            "kvm.ignore_msrs=1"
            "kvm.report_ignored_msrs=0"
            "pcie_acs_override=downstream,multifunction"
          ];
        };

        environment.systemPackages = with pkgs; [
          looking-glass-client
          pciutils
        ];

        services.udev.extraRules = ''
          SUBSYSTEM=="vfio", OWNER="root", GROUP="kvm"
          SUBSYSTEM=="kvmfr", OWNER="root", GROUP="kvm", MODE="0660"
        '';

        systemd.services.nvidia-powerd.enable = false;
      };
  };
}
