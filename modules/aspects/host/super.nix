{ den, ... }:
{
  den.aspects.super = {
    includes = [
      den.aspects.disk.btrfs
      den.aspects.impermanence
    ];

    nixos =
      { lib, pkgs, ... }:
      {
        # Hardware modules matching current hardware.nix
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
        # Bootloader configuration
        boot.loader.systemd-boot.enable = lib.mkDefault true;

        # Base system packages
        environment.systemPackages = with pkgs; [
          git
          vim
          curl
          wget
        ];

        networking.hostName = "super";
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      };

    # Baseline Home-Manager defaults provided to users on this host
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
