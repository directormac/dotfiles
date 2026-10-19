# Host "nixos": Secondary / standard interactive workstation
{
  den,
  ...
}:
{
  den.aspects.nixos = {
    includes = with den.aspects; [
      roles.default
      roles.workstation
      roles.dev
      roles.gaming

      hardware.nixos
      secrets.agenix
      virtualization.vm-variant
      (den.batteries.vm-autologin "artifex")

      impermanence
    ];

    nixos =
      { lib, pkgs, ... }:
      {
        boot.initrd.availableKernelModules = [
          "xhci_pci"
          "ahci"
          "nvme"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];

        boot.kernelModules = [ "kvm-intel" ];
        boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
        boot.loader.systemd-boot.enable = lib.mkDefault true;

        environment.systemPackages = with pkgs; [
          git
          vim
          curl
          wget
        ];

        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      };

    description = "NixOS Workstation";
  };

  den.hosts.x86_64-linux.nixos = {
    description = "NixOS Workstation";
    isWorkstation = true;
    users.artifex = { };
  };
}
