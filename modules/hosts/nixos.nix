# Host "nixos": Secondary / standard interactive workstation
{
  core,
  den,
  lib,
  ...
}:
{
  den.hosts.x86_64-linux.nixos = {
    description = "NixOS Workstation";
    isWorkstation = true;
    users.artifex = { };
  };

  den.aspects.nixos = {
    description = "NixOS Workstation";
    isWorkstation = true;

    includes = with den.aspects; [
      roles.default
      roles.workstation
      roles.dev
      roles.gaming

      hardware.nixos
      secrets.agenix
      core.vm
      (den.batteries.vm-autologin "artifex")
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

        networking.hostName = "nixos";
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      };

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
}
