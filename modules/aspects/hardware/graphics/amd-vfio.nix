# Hardware Graphics AMD VFIO Passthrough Leaf Aspect
{ den, ... }:
{
  den.aspects.hardware.graphics.amd-vfio = {
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

        amdCard = lib.lists.findFirst (
          card:
          (card ? vendor && card.vendor ? name && (
            card.vendor.name == "Advanced Micro Devices, Inc."
            || card.vendor.name == "AMD"
            || card.vendor.name == "ATI Technologies Inc"
          ))
          || (card ? vendor && card.vendor ? hex && card.vendor.hex == "1002")
        ) null facterCards;

        amdGpuDeviceID =
          if amdCard != null && amdCard ? vendor && amdCard ? device then
            "${amdCard.vendor.hex}:${amdCard.device.hex}"
          else
            "1002:747e";

        amdAudioController = lib.lists.findFirst (
          card:
          (card ? vendor && card.vendor ? name && (
            card.vendor.name == "Advanced Micro Devices, Inc."
            || card.vendor.name == "AMD"
            || card.vendor.name == "ATI Technologies Inc"
          ))
          || (card ? vendor && card.vendor ? hex && card.vendor.hex == "1002")
        ) null facterSounds;

        amdAudioDeviceID =
          if amdAudioController != null && amdAudioController ? vendor && amdAudioController ? device then
            "${amdAudioController.vendor.hex}:${amdAudioController.device.hex}"
          else
            "1002:ab30";
      in
      {
        services.udev.extraRules = ''
          SUBSYSTEM=="vfio", OWNER="root", GROUP="kvm"
          SUBSYSTEM=="kvmfr", OWNER="root", GROUP="kvm", MODE="0660"
        '';

        boot = {
          kernelParams = [
            "vfio-pci.ids=${amdGpuDeviceID},${amdAudioDeviceID}"
            "vfio_iommu_type1.allow_unsafe_interrupts=1"
            "kvm.ignore_msrs=1"
            "kvm.report_ignored_msrs=0"
            "pcie_acs_override=downstream,multifunction"
          ];

          initrd.kernelModules = [
            "vfio_pci"
            "vfio"
            "vfio_iommu_type1"
            "kvmfr"
          ];

          extraModulePackages = [
            config.boot.kernelPackages.kvmfr
          ];

          blacklistedKernelModules = [
            "amdgpu"
            "radeon"
          ];

          extraModprobeConfig = ''
            options vfio-pci ids=${amdGpuDeviceID},${amdAudioDeviceID}
            options kvmfr static_size_mb=256
            options kvm_amd nested=1 avic=1 npt=1 sev=0
            options kvm_intel nested=1
            options vfio_iommu_type1 allow_unsafe_interrupts=1
            blacklist amdgpu
            blacklist radeon
          '';
        };

        environment.systemPackages = with pkgs; [
          looking-glass-client
          pciutils
        ];
      };
  };
}
