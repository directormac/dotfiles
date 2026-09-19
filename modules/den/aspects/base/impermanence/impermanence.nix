{
  den,
  lib,
  inputs,
  ...
}: {
  den.aspects.base.impermanence = {
    includes = [
      den.aspects.base.impermanence.persist-collector
      den.aspects.base.impermanence.persist-home-collector
      den.aspects.base.impermanence.btrfs
    ];

    settings = {
      wipeRootOnBoot = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Roll the root filesystem back to a pristine state on boot";
      };
      wipeHomeOnBoot = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Roll the home filesystem back to a pristine state on boot";
      };
    };

    nixos = _: {
      imports = [
        inputs.impermanence.nixosModules.impermanence
      ];

      options.impermanence.ignorePaths = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Paths ignored by persistence diff tooling.";
      };

      config = {
        impermanence.ignorePaths = [
          "/etc/NIXOS"
          "/etc/.clean"
          "/etc/.updated"
          "/etc/.pwd.lock"
          "/var/.updated"
          "/etc/subgid"
          "/etc/subuid"
          "/etc/shadow"
          "/etc/group"
          "/etc/passwd"
          "/root/.nix-channels"
          "/var/lib/systemd/linger/"
          "/var/lib/systemd/random-seed"
          "/etc/fwupd/fwupd.conf"
          "/var/lib/tpm2-udev-trigger/hash.txt"
          "/etc/ssh/authorized_keys.d/"
        ];

        # Fix /var/lib and /var/lib/private permissions after impermanence creates them
        system.activationScripts."var-lib-private-perms" = {
          deps = [
            "persist-files"
            "createPersistentStorageDirs"
          ];
          text = ''
            mkdir -p /var/lib/private
            chown root:root /var/lib
            chmod 0755 /var/lib
            chown root:root /var/lib/private
            chmod 0700 /var/lib/private
          '';
        };

        environment.persistence = {
          "/cache" = {
            enable = true;
            persistentStoragePath = "/cache";
            hideMounts = true;
            directories = [
              "/var/lib/nixos"
              "/var/tmp"
              "/srv"
            ];
          };

          "/persist" = {
            enable = true;
            hideMounts = true;
            directories = [];
            files = [
              "/etc/machine-id"
              "/etc/adjtime"
              "/root/.bash_history"
              "/var/lib/systemd/credential.secret"
            ];
          };
        };
      };
    };

    # Home Manager persistence
    homeManager = {
      home.persistence = {
        "/persist" = {
          directories = [
            "Desktop"
            "Documents"
            "Music"
            "Pictures"
            "Public"
            "Templates"
            "Videos"
            {
              directory = ".ssh";
              mode = "0700";
            }
            {
              directory = ".local/share/keyrings";
              mode = "0700";
            }
          ];
        };

        "/cache" = {
          directories = [
            "Downloads"
            ".local/share/direnv"
            ".local/share/nix"
            ".cache"
          ];
        };
      };
    };
  };
}
