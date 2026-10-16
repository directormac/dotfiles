# Hardware Configuration for Host "nixos"
_:
{
  den.aspects.hardware.nixos = {
    nixos =
      {
        config,
        lib,
        modulesPath,
        ...
      }:
      {
        boot.extraModulePackages = [ ];

        boot.initrd.availableKernelModules = [
          "xhci_pci"
          "ahci"
          "nvme"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];

        boot.initrd.kernelModules = [ ];
        boot.kernelModules = [ "kvm-intel" ];

        fileSystems."/" = {
          device = "/dev/disk/by-uuid/dcd3cd20-f5d6-4bf9-8670-cdf6dfb7c923";
          fsType = "btrfs";
        };

        fileSystems."/boot" = {
          options = [
            "fmask=0077"
            "dmask=0077"
          ];

          device = "/dev/disk/by-uuid/6DC1-EF87";
          fsType = "vfat";
        };

        fileSystems."/home" = {
          options = [ "subvol=home" ];
          device = "/dev/disk/by-uuid/dcd3cd20-f5d6-4bf9-8670-cdf6dfb7c923";
          fsType = "btrfs";
        };

        fileSystems."/nix" = {
          options = [ "subvol=nix" ];
          device = "/dev/disk/by-uuid/dcd3cd20-f5d6-4bf9-8670-cdf6dfb7c923";
          fsType = "btrfs";
        };

        hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

        imports = [
          (modulesPath + "/installer/scan/not-detected.nix")
        ];

        swapDevices = [
          { device = "/dev/disk/by-uuid/bda3bb35-7c47-4e92-88af-8daadf439719"; }
        ];
      };
  };

}
