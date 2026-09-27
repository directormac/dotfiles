{lib, ...}: {
  den.aspects.vmzero.nixos = {modulesPath, ...}: {
    imports = [(modulesPath + "/profiles/qemu-guest.nix")];

    boot = {
      initrd.availableKernelModules = [
        "ata_piix"
        "sr_mod"
        "uhci_hcd"
        "virtio_pci"
        "virtio_scsi"
        "ahci"
        "sr_mod"
        "virtio_blk"
        "virtio_pci"
        "xhci_pci"
      ];
      initrd.kernelModules = [];
      kernelModules = ["kvm-intel"];
      extraModulePackages = [];
    };
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
