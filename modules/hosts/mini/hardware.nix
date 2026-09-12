{lib, ...}: {
  den.aspects.mini.nixos = {modulesPath, ...}: {
    imports = [(modulesPath + "/profiles/qemu-guest.nix")];

    /**
    [boot.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/system/boot/stage-1-init.sh)
    [Options](https://search.nixos.org/options?channel=unstable&query=boot.&type=options)
    */
    boot = {
      /**
      ## Could be grub or systemd-boot
      [loader.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/system/boot/loader/loader.nix)
      [Options](https://search.nixos.org/options?channel=unstable&query=boot.loader&type=options)
      */
      loader = {
      };

      /**
      [kernel.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/system/boot/kernel.nix#L200)
      [Linux Kernel](https://nixos.wiki/wiki/Linux_kernel)
      */
      kernelModules = ["kvm-intel"];

      # [initrd.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/system/boot/stage-1.nix)
      initrd = {
        kerNelModules = [];
        availableKernelModules = [
          "ahci"
          "ata_piix"
          "uhci_hcd"
          "virtio_pci"
          "virtio_scsi"
          "xhci_pci"
          "sd_mod"
          "sr_mod"
          "virtio_blk"
        ];
      };
      # [kernel.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/system/boot/kernel.nix#L193)
      extraModulePackages = [];
    };

    /**
    [useDHCP](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/tasks/network-interfaces.nix#L220)
    */
    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
