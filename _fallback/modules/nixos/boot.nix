{ ... }: {
  flake.nixosModules.base = { pkgs, ... }: {

    # Bootloader.

    # Use latest kernel.
    boot.kernelPackages = pkgs.linuxPackages_latest;

    boot = {
      plymouth = {
        enable = true;
      };

      # Enable "Silent boot"
      consoleLogLevel = 0;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "rd.udev.log_level=3"
        "rd.systemd.show_status=auto"
      ];

      # Hide the OS choice for bootloaders.
      # It's still possible to open the bootloader list by pressing any key
      # It will just not appear on screen unless a key is pressed
      loader = {
        timeout = 3;
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
        systemd-boot.configurationLimit = 10;
      };

      initrd.kernelModules = [
        "amdgpu"
        "i915"
        # "uinput"
      ];
    };

    hardware.uinput.enable = true;

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        # Intel Video Acceleration (VA-API) for 13th Gen UHD 770
        intel-media-driver
        # Intel QuickSync Video runtime for encoding/decoding
        vpl-gpu-rt
        # libva-vdpau-driver
        # mesa
      ];
    };

    services.xserver.videoDrivers = [
      "amdgpu"
      "modesetting"
    ];

  };
}
