{
  __findFile,
  lib,
  den,
  inputs,
  ...
}: let
  hostname = "vmzero";
in {
  flake-file.inputs = {
    disko = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/disko";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  # Define host
  den = {
    hosts.x86_64-linux.${hostname} = {
      users = {
        artifex = {};
      };
    };
    aspects.${hostname} = {
      includes = with den.aspects; [
        zero
      ];
      nixos = {modulesPath, ...}: {
        imports = [
          (modulesPath + "/profiles/qemu-guest.nix")

          inputs.disko.nixosModules.disko
        ];

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
    };
  };
}
