{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.vmachine = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.vmachine
    ];
  };

  flake.nixosModules.vmachine = {
    pkgs,
    config,
    ...
  }: {
    imports = [
      self.nixosModules.vmachineHardware

      inputs.home-manager.nixosModules.default
      self.nixosModules.base
      self.nixosModules.general
      self.nixosModules.desktop

      inputs.disko.nixosModules.disko
      self.diskoConfigurations.vmachine
    ];

    networking.hostName = "vmachine"; # Define your hostname.

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
        systemd-boot.configurationLimit = 2;
        efi.canTouchEfiVariables = true;
      };

      # Use latest kernel.
      kernelPackages = pkgs.linuxPackages_latest;
    };

    services = {
      # displayManager = {
      #   autoLogin = {
      #     enable = true;
      #     user = "artifex";
      #   };
      # };

      spice-vdagentd.enable = true;

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

    home-manager.users.${config.preferences.user.name} = {
      config,
      lib,
      ...
    }: {
      home.stateVersion = "26.05";
      systemd.user.services.spice-vdagent = {
        Unit = {
          Description = "Spice guest desktop agent";
          PartOf = ["graphical-session.target"];
        };
        Install = {
          WantedBy = ["graphical-session.target"];
        };
        Service = {
          ExecStart = "${pkgs.spice-vdagent}/bin/spice-vdagent -x";
        };
      };
    };

    # fileSystems."/home/artifex/Public" = {
    #   device = "vshare";
    #   fsType = "virtiofs";
    #   options = ["defaults"];
    # };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Enable networking
    networking.networkmanager.enable = true;

    i18n.defaultLocale = "en_PH.UTF-8";

    system.stateVersion = "26.05";
  };
}
