{
  den,
  inputs,
  ...
}: {
  den.hosts.x86_64-linux.sandbox = {
    # channel = "nixpkgs";
    # environment = "dev";
    system-owner = "mac";
    system-access-groups = ["workstation-access"];

    # networking.interfaces.wlp0s20f3 = {
    #   dhcp = "yes";
    # };

    settings = {
      # base.impermanence = {
      #   wipeRootOnBoot = true;
      #   wipeHomeOnBoot = false;
      # };
    };
  };

  den.aspects.sandbox = {
    includes = with den.aspects; [
      roles.default
      roles.dev
      roles.workstation

      hardware.cpu.intel
      hardware.performance

      desktop.wayland
      desktop.ly

      base.network.manager
      # core.network.tailscale
    ];

    nixos = {
      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };

      users.allowNoPasswordLogin = true;

      services.openssh = {
        enable = true;
        settings.PermitRootLogin = "yes";
      };

      virtualisation.vmVariant = {
        virtualisation.forwardPorts = [
          {
            from = "host";
            host.port = 2222;
            guest.port = 22;
          }
        ];
      };
    };

    mac = {
      includes = with den.aspects; [
        applications.terminal.ghostty
        # applications.wayland.waybar
        # applications.wayland.swaync
        # applications.wayland.hypridle
        # applications.wayland.hyprland-split-monitors
        # applications.media.spotify-player
      ];
    };
  };
}
