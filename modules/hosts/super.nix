# Host "super": Primary interactive workstation
{
  den,
  ...
}:
{
  den.aspects.super = {
    includes = with den.aspects; [
      roles.default
      roles.workstation
      roles.dev
      roles.gaming

      secrets.agenix
      virtualization.vm-variant
      (den.batteries.vm-autologin "artifex")

      disk.btrfs
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

        hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
        hardware.enableRedistributableFirmware = lib.mkDefault true;
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      };

    description = "Super Workstation";
  };

  den.hosts.x86_64-linux.super = {
    settings.desktop.hyprland.cardDevice = "/dev/dri/card2:/dev/dri/card1";
    settings.disk.btrfs.device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNX0W399283A";
    description = "Super Workstation";
    isWorkstation = true;
    users.artifex = { };
  };
}
