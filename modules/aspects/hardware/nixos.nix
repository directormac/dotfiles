# Hardware Configuration for Host "nixos"
{
  core,
  den,
  ...
}:
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
        imports = [
          (modulesPath + "/installer/scan/not-detected.nix")
        ];

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
        boot.extraModulePackages = [ ];

        fileSystems."/" = {
          device = "/dev/disk/by-uuid/dcd3cd20-f5d6-4bf9-8670-cdf6dfb7c923";
          fsType = "btrfs";
        };

        fileSystems."/home" = {
          device = "/dev/disk/by-uuid/dcd3cd20-f5d6-4bf9-8670-cdf6dfb7c923";
          fsType = "btrfs";
          options = [ "subvol=home" ];
        };

        fileSystems."/nix" = {
          device = "/dev/disk/by-uuid/dcd3cd20-f5d6-4bf9-8670-cdf6dfb7c923";
          fsType = "btrfs";
          options = [ "subvol=nix" ];
        };

        fileSystems."/boot" = {
          device = "/dev/disk/by-uuid/6DC1-EF87";
          fsType = "vfat";
          options = [
            "fmask=0077"
            "dmask=0077"
          ];
        };

        swapDevices = [
          { device = "/dev/disk/by-uuid/bda3bb35-7c47-4e92-88af-8daadf439719"; }
        ];

        hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
  };

}
