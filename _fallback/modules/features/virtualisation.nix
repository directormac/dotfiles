{ self, ... }: {
  flake.homeModules.virtualisation = { pkgs, ... }: {

    systemd.user.services.waydroid-session = {
      Unit = {
        Description = "Waydroid User Session";
        After = [ "waydroid-container.service" ];
        # Requires = [ "waydroid-container.service" ];
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        Type = "simple";

        # Inject the active user path environment
        # Environment = [
        #   "PATH=${pkgs.waydroid}/bin:${pkgs.coreutils}/bin"
        #   "DBUS_SESSION_BUS_ADDRESS=unix:path=%t/bus"
        # ];

        ExecStart = "${pkgs.waydroid}/bin/waydroid session start";
        ExecStop = "${pkgs.waydroid}/bin/waydroid session stop";

        # Clean up processes on exit
        KillMode = "mixed";

        # Resource limits: 4GB Max, 3GB cache threshold
        MemoryMax = "8G";
        MemoryHigh = "6G";

        TimeoutStopSec = "15s";
        Restart = "on-failure";
      };
    };

  };
  flake.nixosModules.virtualisation = { pkgs, config, ... }: {

    home-manager.users.${config.preferences.user.name} = {
      imports = with self.homeModules; [
        virtualisation
      ];
    };

    #https://nixos.org/wiki/Podman
    environment = {
      systemPackages = with pkgs; [
        waydroid
        waydroid-helper

        podman-compose

        lsof
        dnsmasq
        virt-viewer
        spice
        spice-gtk
        spice-protocol
        lazydocker

        clinfo
        libva-utils
      ];
    };

    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv4.conf.all.forwarding" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    # networking.nftables.enable = true;

    networking.firewall.trustedInterfaces = [
      "virbr0"
      "waydroid0"
    ];

    programs.virt-manager = {
      enable = true;

    };

    virtualisation.podman = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
      defaultNetwork.settings.dns_enabled = true;
      dockerCompat = true;
      dockerSocket.enable = true;

      # https://github.com/ghostunnel/ghostunnel
      # dockerSocket.enable = true;
      # networkSocket = {
      #   enable = true;
      #   server = "ghostunnel";
      #   openFirewall = true;
      # };
    };

    virtualisation.waydroid = {
      enable = true;
      # package = pkgs.waydroid-nftables;
      package = pkgs.waydroid.override {
        # If your host is using nftables (NixOS default for newer versions), make sure waydroid targets it
        withNftables = true;
      };
    };

    virtualisation.libvirtd = {
      enable = true;

      qemu = {
        vhostUserPackages = with pkgs; [ virtiofsd ];
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;

        # Enable QEMU graphics support to allow shared iGPU contexts via Spice/VirGL
        verbatimConfig = ''
          graphics_provider = "spice"
        '';
      };
    };

  };
}
