# Baseline system settings: boot, localisation, networking, security, nix daemon
{
  core,
  ...
}:
{
  core.system.base = {
    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        # Boot & Kernel
        boot = {
          consoleLogLevel = lib.mkDefault 0;

          initrd.kernelModules = [
            "amdgpu"
            "i915"
          ];

          initrd.verbose = lib.mkDefault false;
          kernel.sysctl."kernel.perf_event_paranoid" = 0;
          kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

          kernelParams = [
            "quiet"
            "rd.udev.log_level=3"
            "rd.systemd.show_status=auto"
          ];

          loader = {
            efi.canTouchEfiVariables = lib.mkDefault true;

            systemd-boot = {
              configurationLimit = lib.mkDefault 10;
              enable = lib.mkDefault true;
            };

            timeout = lib.mkDefault 3;
          };

          plymouth.enable = lib.mkDefault true;
        };

        environment.systemPackages = with pkgs; [
          polkit_gnome
          networkmanagerapplet
        ];

        # File system mounts (CIFS when secrets available, NTFS local data)
        fileSystems = lib.mkMerge [
          (lib.mkIf (config.age.secrets ? fileserver-smb-secrets) {
            "/mnt/network/fileserver" = {
              options =
                let
                  automount_opts = "x-systemd.automount,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
                in
                [
                  "${automount_opts},credentials=${config.age.secrets.fileserver-smb-secrets.path},uid=1000,gid=1000"
                  "nofail"
                ];

              device = "//fileserver/data";
              fsType = "cifs";
            };
          })
          {
            "/mnt/local/resources" = {
              options = [
                "defaults"
                "uid=1000"
                "gid=1000"
                "dmask=022"
                "fmask=133"
                "nofail"
              ];

              device = "/dev/disk/by-uuid/50AAE2C51C074C8E";
              fsType = "ntfs3";
            };
          }
        ];

        hardware.bluetooth.enable = lib.mkDefault true;

        hardware.graphics = {
          enable = lib.mkDefault true;
          enable32Bit = lib.mkDefault true;

          extraPackages = with pkgs; [
            intel-media-driver
            vpl-gpu-rt
          ];
        };

        # Hardware & Graphics
        hardware.uinput.enable = lib.mkDefault true;
        i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

        # Networking
        networking = {
          firewall = {
            allowedTCPPortRanges = [
              {
                from = 1714;
                to = 1764;
              }
            ];

            allowedTCPPorts = [
              22
              80
              443
              445
              59010
              59011
              8080
            ];

            allowedUDPPortRanges = [
              {
                from = 1714;
                to = 1764;
              }
            ];

            allowedUDPPorts = [
              137
              138
              59010
              59011
            ];

            enable = lib.mkDefault true;
          };

          hosts = {
            "192.168.66.100" = [ "fileserver" ];
          };

          networkmanager.enable = lib.mkDefault true;
        };

        # Nix settings
        nix = {
          settings = {
            accept-flake-config = true;
            auto-optimise-store = true;

            experimental-features = [
              "nix-command"
              "flakes"
            ];

            keep-derivations = true;

            substituters = [
              "https://cache.nixos.org"
              "https://nix-community.cachix.org"
              "https://cachix.cachix.org"
              "https://cache.numtide.com"
            ];

            trusted-public-keys = [
              "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
              "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
            ];

            trusted-users = [
              "root"
              "@wheel"
              "artifex"
            ];

            use-xdg-base-directories = true;
          };

          gc = {
            options = "--delete-older-than 10d";
            automatic = true;
            dates = "00:01";
          };

          optimise = {
            automatic = true;
            dates = [ "05:00" ];
          };
        };

        nixpkgs.config.allowUnfree = true;

        programs.ssh.extraConfig = ''
          Host github.com
            Hostname ssh.github.com
            Port 443
            User git
        '';

        # Security
        security = {
          pam.services = {
            gdm.enableGnomeKeyring = true;
            gdm-password.enableGnomeKeyring = true;
            login.enableGnomeKeyring = true;
          };

          polkit = {
            enable = lib.mkDefault true;
            enablePkexecWrapper = lib.mkDefault true;
          };

          rtkit.enable = lib.mkDefault true;
          sudo.extraConfig = "Defaults pwfeedback";
        };

        services.avahi = {
          browseDomains = [ ];
          enable = lib.mkDefault true;
          nssmdns4 = lib.mkDefault true;
        };

        # Network services
        services.gvfs.enable = lib.mkDefault true;

        # OpenSSH daemon
        services.openssh = {
          settings = {
            KbdInteractiveAuthentication = lib.mkDefault true;
            PasswordAuthentication = lib.mkDefault true;
            PermitRootLogin = lib.mkOptionDefault "prohibit-password";
            UseDns = lib.mkDefault true;
            X11Forwarding = lib.mkDefault false;
          };

          enable = lib.mkDefault true;
          ports = lib.mkDefault [ 22 ];
        };

        services.samba-wsdd = {
          enable = lib.mkDefault true;
          openFirewall = true;
        };

        services.smartd = {
          autodetect = true;
          enable = lib.mkDefault true;
        };

        services.xserver.videoDrivers = lib.mkDefault [
          "amdgpu"
          "modesetting"
        ];

        systemd.user.services.polkit-gnome-authentication-agent-1 = {
          after = [ "graphical-session.target" ];
          description = "polkit-gnome-authentication-agent-1";

          serviceConfig = {
            ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
            Type = "simple";
          };

          wantedBy = [ "graphical-session.target" ];
          wants = [ "graphical-session.target" ];
        };

        # Time and Locale
        time.timeZone = lib.mkDefault "Asia/Manila";
      };

    # Persistent network connections across impermanence boots
    persist.directories = [
      "/etc/NetworkManager/system-connections"
    ];
  };

  den.aspects.nixos.includes = [
    core.system.base
  ];

  den.aspects.sandbox.includes = [
    core.system.base
  ];

  # Attach core.system.base to super, nixos, and sandbox
  den.aspects.super.includes = [
    core.system.base
  ];
}
