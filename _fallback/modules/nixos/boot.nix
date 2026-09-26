{ ... }: {
  flake.nixosModules.base = { pkgs, ... }: {

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.loader.systemd-boot.configurationLimit = 10;

    # Use latest kernel.
    boot.kernelPackages = pkgs.linuxPackages_latest;
  };
}
