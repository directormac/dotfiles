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

        networking.hostName = "super";
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      };

    description = "Super Workstation";
    isWorkstation = true;

    provides.to-users.homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          htop
          ripgrep
          fd
        ];
      };
  };

  den.hosts.x86_64-linux.super = {
    settings.desktop.hyprland.cardDevice = "/dev/dri/card2:/dev/dri/card1";
    description = "Super Workstation";
    isWorkstation = true;
    users.artifex = { };
  };
}
