{ self, ... }: {
  flake.homeModules.virtualisation = { pkgs, ... }: {

    systemd.user.services.waydroid-session = {
      Unit = {
        Description = "Waydroid User Session";
        After = [ "waydroid-container.service" ];
        # Requires = [ "waydroid-container.service" ];

        # Ensures that if this session is no longer actively tied to
        # a running waydroid client/process, it winds itself down.
        StopWhenUnneeded = true;
      };
      Install = {
        # WantedBy = [ "default.target" ];
        WantedBy = [ ];
      };
      Service = {
        Type = "simple";

        # Wake up the root container service if it isn't running
        #
        # ExecStartPre = "${pkgs.systemd}/bin/systemctl start waydroid-container.service";

        ExecStart = "${pkgs.waydroid}/bin/waydroid session start";
        ExecStop = "${pkgs.waydroid}/bin/waydroid session stop";

        # Clean up processes on exit
        KillMode = "mixed";

        # Excellent resource boundary strategies preserved
        MemoryMax = "8G";
        MemoryMin = "256M";
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
    };

    # networking.nftables.enable = true;

    networking.firewall.trustedInterfaces = [
      "virbr0"
      "waydroid0"
    ];

    networking.firewall.allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];

    networking.firewall.allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
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
      # defaultNetwork.settings.dns_enabled = true;
      dockerCompat = true;
      dockerSocket.enable = true; # Handled gracefully by Podman's default netavark backend now

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
      package = pkgs.waydroid.override {
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
