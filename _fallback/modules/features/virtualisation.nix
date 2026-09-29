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
        waydroid-helper
        dnsmasq
      ];
    };

    networking.firewall.trustedInterfaces = [ "virbr0" ];

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
      };
    };

  };
}
