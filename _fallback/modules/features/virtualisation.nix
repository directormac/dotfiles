{ self, ... }: {
  flake.homeModules.virtualisation = {

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
      "net.ipv6.conf.all.forwarding" = 1;
    };

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
