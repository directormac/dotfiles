{ inputs, ... }: {
  flake.nixosModules.base = { pkgs, ... }: {

    imports = [
      inputs.nix-index-database.nixosModules.nix-index
    ];

    # Enable the X11 windowing system.
    services.xserver = {
      enable = true;

      exportConfiguration = true;
      xkb = {
        layout = "us";
        variant = "";
      };

    };

    # Enable the GNOME Desktop Environment.
    # services.displayManager.gdm.enable = true;
    # services.desktopManager.gnome.enable = true;

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    programs = {
      xfconf.enable = true;
      nix-index-database.comma.enable = true;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    security = {
      rtkit.enable = true;
      polkit.enable = true;
      pam.services = {
        gdm.enableGnomeKeyring = true;
        gdm-password.enableGnomeKeyring = true;
        login.enableGnomeKeyring = true;
      };
      sudo.extraConfig = "Defaults pwfeedback";

      # apparmor = {
      #   enable = true;
      #   killUnconfinedConfinables = true;
      #   packages = [ pkgs.apparmor-profiles ];
      # };

    };

  };
}
