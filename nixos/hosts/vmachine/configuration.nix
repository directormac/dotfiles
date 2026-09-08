{ self, ... }: {
  flake.nixosModules.vmachineConfiguration = { pkgs, lib, ... }: {

    imports = [
      self.nixosModules.vmachineHardware

      self.nixosModules.base
      self.nixosModules.general
      self.nixosModules.desktop

    ];

    environment = {
      sessionVariables = {
        WLR_NO_HARDWARE_CURSORS = "1";
        #	WLR_RENDERER = "pixman";
      };
    };

    boot = {
      loader = {
        # Use the systemd-boot EFI boot loader.
        systemd-boot.enable = true;
        systemd-boot.configurationLimit = 4;
        efi.canTouchEfiVariables = true;
      };

      # Use latest kernel.
      kernelPackages = pkgs.linuxPackages_latest;
    };

    services = {

      displayManager = {
        autoLogin = {
          enable = true;
          user = "artifex";
        };
      };

      spice-vdagentd.enable = true;

      # Enable the GNOME Desktop Environment.
      # displayManager.gdm.enable = true;
      # desktopManager.gnome.enable = true;

      openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = true;
        };
      };

      # Configure keymap in X11
      xserver.xkb = {
        layout = "us";
        variant = "";
      };

      # Enable sound with pipewire.
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;

        # Use the WirePlumber session manager
        #wireplumber.enable = true;
      };

    };

    security.rtkit.enable = true;

    fileSystems."/home/artifex/Public" = {
      device = "vshare";
      fsType = "virtiofs";
      options = [ "defaults" ];
    };

    fileSystems."/home/artifex/.dotfiles" = {
      device = "vdotfiles";
      fsType = "virtiofs";
      options = [ "defaults" ];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    networking.hostName = "vmachine"; # Define your hostname.

    # Enable networking
    networking.networkmanager.enable = true;

    i18n.defaultLocale = "en_PH.UTF-8";

    system.stateVersion = "26.05";
  };
}
