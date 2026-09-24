{ core, ... }: {
  # --- Host Configuration Aspect ---
  den.aspects.sandbox = {
    # NixOS configuration for sandbox.
    nixos = _: {
      # environment.systemPackages = [ pkgs.hello ];
      #
      # fileSystems."/" = {
      #   device = "/dev/disk/by-label/nixos";
      #   fsType = "ext4";
      # };

      nixpkgs = {
        config = {
          # Disable if you don't want unfree packages
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
      };

      # Use ly as the default display manager for the sandbox
      services.displayManager.ly.enable = true;

      # Enable SSH for easier debugging
      services.openssh = {
        settings.PermitRootLogin = "yes";
        enable = true;
      };
    };

    # sandbox host provides some home-manager defaults to its users.
    homeManager.programs.direnv.enable = true;
    description = "NixOS sanbox";
    isWorkstation = false;

    users = {
      mac = {
        description = "Mac";
        userNameNick = "Mac";
        userNameReal = "Mac mac mac";
      };
    };
  };

  den.aspects.sandbox.includes = [
    # From the aspect tree.
    # core.systemd-boot
    core.system

    core.shell
    core.utils
  ];

  den.hosts.x86_64-linux.sandbox.users.mac = { };
}
