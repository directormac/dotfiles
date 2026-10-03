{
  flake.nixosModules.base = { pkgs, config, ... }: {
    networking = {

      hosts = {
        "192.168.66.100" = [ "fileserver" ];
      };

      hostName = "nixos"; # Define your hostname.
      # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

      # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      # Enable networking
      networkmanager.enable = true;

      # Open ports in the firewall.
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      # networking.firewall.enable = false;

      firewall = {
        enable = true;
        allowedTCPPorts = [
          22
          80
          443
          445
          59010
          59011
          8080
        ];
        allowedUDPPorts = [
          137
          138
          59010
          59011
        ];

        # KDE Connect
        allowedTCPPortRanges = [
          {
            from = 1714;
            to = 1764;
          }
        ];

        # KDE Connect
        allowedUDPPortRanges = [
          {
            from = 1714;
            to = 1764;
          }
        ];
      };

    };

    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = true;
        AllowGroups = null;
        UseDns = true;
        X11Forwarding = false;
        PermitRootLogin = "prohibit-password";
      };
    };

    services.gvfs.enable = true;

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      browseDomains = [ ];
    };

    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };

    programs.kdeconnect = {
      enable = true;
      # package = pkgs.valent;
    };

    services.smartd = {
      enable = true;
      autodetect = true;
    };

    programs.ssh.extraConfig = ''
      Host github.com
        Hostname ssh.github.com
        Port 443
        User git
    '';

    environment.systemPackages = with pkgs; [
      networkmanagerapplet
    ];

    # ── SMB/CIFS mount — template: fill in device + credentials, uncomment ──
    fileSystems."/mnt/network/fileserver" = {
      device = "//fileserver/data";
      fsType = "cifs";
      options =
        let
          automount_opts = "x-systemd.automount,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
        in
        [
          "${automount_opts},credentials=${
            config.age.secrets."fileserver-smb-secrets".path
          },uid=1000,gid=1000"
          "nofail"
        ];
    };

    fileSystems."/mnt/local/resources" = {
      device = "/dev/disk/by-uuid/50AAE2C51C074C8E";
      fsType = "ntfs3"; # Modern, fast kernel driver (or "ntfs-3g" if using legacy user-space driver)
      options = [
        "defaults"
        "uid=1000"
        "gid=1000"
        "dmask=022"
        "fmask=133"
        "nofail" # Highly recommended: prevents NixOS from locking up on boot if the drive is unplugged
      ];
    };

  };
}
