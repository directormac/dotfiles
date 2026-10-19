{
  lib,
  den,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    impermanence.url = "github:nix-community/impermanence";
  };

  den.aspects.impermanence = {
    includes = [
      den.aspects.impermanence.collect
      den.aspects.impermanence.tmpfs
      den.aspects.impermanence.rollback-btrfs
    ];

    settings = {
      wipeHomeOnBoot = lib.mkOption {
        default = false;
        description = "Roll the home filesystem back to a pristine state on boot";
        type = lib.types.bool;
      };

      wipeRootOnBoot = lib.mkOption {
        default = true;
        description = "Roll the root filesystem back to a pristine state on boot";
        type = lib.types.bool;
      };
    };

    nixos = {
      options.impermanence.ignorePaths = lib.mkOption {
        default = [ ];
        description = "Paths ignored by persistence diff tooling.";
        type = lib.types.listOf lib.types.str;
      };

      config = {
        environment.persistence = {
          "/cache" = {
            enable = true;
            hideMounts = true;
            persistentStoragePath = "/cache";
          };

          "/persist" = {
            enable = true;
            hideMounts = true;
          };
        };

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

        # Allow users to mount persistent bind mounts with fuse
        programs.fuse.userAllowOther = true;

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
      };

      imports = [ inputs.impermanence.nixosModules.impermanence ];
    };

    # Static system paths go through the quirks pools like every aspect's,
    # so `persist` and `cache` carry the complete set merged by `impermanence.collect`.
    cache.directories = [
      "/var/tmp"
      "/srv"
    ];

    cacheHome.directories = [
      "Downloads"
      ".local/share/nix"
      ".cache"
    ];

    darwin = _: {
      options.environment.persistence = lib.mkOption {
        default = { };
        description = "Dummy persistence option for Darwin (no-op).";
        type = lib.types.anything;
      };

      config = {
        home-manager.sharedModules = [
          {
            options.home.persistence = lib.mkOption {
              default = { };
              description = "Dummy persistence option for Darwin (no-op).";
              type = lib.types.anything;
            };
          }
        ];
      };
    };

    persist = {
      directories = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
      ];

      files = [
        "/etc/machine-id"
        "/etc/adjtime"
        "/root/.bash_history"
        # Host key for systemd LoadCredentialEncrypted. Must persist so
        # blobs encrypted against it (e.g. libvirt's secrets-encryption-key
        # under the persisted /var/lib/libvirt) stay decryptable across boots.
        "/var/lib/systemd/credential.secret"
      ];
    };

    # Sane default home persistence directories
    persistHome.directories = [
      "Desktop"
      "Documents"
      "Music"
      "Pictures"
      "Public"
      "Templates"
      "Videos"
      "Code"
      "Projects"
      "Notes"
      "Work"
      ".dotfiles"
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

  # Collector aspect: reads the four persistence quirks and passes merged unique lists to impermanence
  den.aspects.impermanence.collect = {
    nixos =
      {
        lib,
        cache,
        persist,
        ...
      }:
      let
        dirPath = d: lib.removeSuffix "/" (if builtins.isAttrs d then d.directory else d);
        flatten = lib.concatMap (e: if builtins.isList e then e else [ e ]);
        merge =
          entries:
          let
            dirStrings = map dirPath rawDirs;
            flat = flatten entries;
            isSubpath = p: builtins.any (parent: parent != p && lib.hasPrefix "${parent}/" p) dirStrings;
            rawDirs = lib.unique (lib.concatMap (e: e.directories or [ ]) flat);
          in
          {
            directories = builtins.filter (d: !isSubpath (dirPath d)) rawDirs;
            files = lib.unique (lib.concatMap (e: e.files or [ ]) flat);
          };
      in
      {
        environment.persistence."/cache" = merge cache;
        environment.persistence."/persist" = merge persist;
      };

    homeManager =
      {
        lib,
        cacheHome,
        persistHome,
        ...
      }:
      let
        dirPath =
          d: lib.removeSuffix "/" (lib.removePrefix "~/" (if builtins.isAttrs d then d.directory else d));
        flatten = lib.concatMap (e: if builtins.isList e then e else [ e ]);
        merge =
          entries:
          let
            dirStrings = map dirPath rawDirs;
            flat = flatten entries;
            isSubpath = p: builtins.any (parent: parent != p && lib.hasPrefix "${parent}/" p) dirStrings;
            rawDirs = lib.unique (map normalizeDir (lib.concatMap (e: e.directories or [ ]) flat));
          in
          {
            directories = builtins.filter (d: !isSubpath (dirPath d)) rawDirs;
            files = lib.unique (lib.concatMap (e: e.files or [ ]) flat);
          };
        normalizeDir = d: if builtins.isAttrs d then d // { directory = dirPath d; } else dirPath d;
      in
      {
        home.persistence."/cache" = (merge cacheHome) // {
          allowTrash = true;
          hideMounts = true;
        };

        home.persistence."/persist" = (merge persistHome) // {
          allowTrash = true;
          hideMounts = true;
        };
      };
  };

  # Btrfs rollback aspect: wipes ephemeral root (and optionally home) and restores blank snapshot on early boot
  den.aspects.impermanence.rollback-btrfs = {
    nixos =
      { host, ... }:
      let
        wipeHome = host.settings.impermanence.wipeHomeOnBoot or false;
        wipeRoot = host.settings.impermanence.wipeRootOnBoot or true;
      in
      {
        boot.initrd.systemd.services = {
          rollback-home = lib.mkIf wipeHome {
            after = [ "initrd-root-device.target" ];
            before = [ "home.mount" ];
            description = "Roll the home subvolume back to empty snapshot";

            script = ''
              if [ ! -b /dev/disk/by-label/nixos ]; then
                echo "No btrfs filesystem labeled 'nixos' found (e.g. running in test VM), skipping home rollback."
                exit 0
              fi
              mkdir -p /mnt-btrfs
              mount -t btrfs -o subvol=/ /dev/disk/by-label/nixos /mnt-btrfs
              if [ -e /mnt-btrfs/home ] && [ -e /mnt-btrfs/home-blank ]; then
                btrfs subvolume list -o /mnt-btrfs/home | cut -f9 -d' ' | while read -r subvol; do
                  btrfs subvolume delete "/mnt-btrfs/$subvol"
                done
                btrfs subvolume delete /mnt-btrfs/home
                btrfs subvolume snapshot /mnt-btrfs/home-blank /mnt-btrfs/home
              fi
              umount /mnt-btrfs
            '';

            serviceConfig.Type = "oneshot";
            unitConfig.DefaultDependencies = "no";
            wantedBy = [ "initrd.target" ];
          };

          rollback-root = lib.mkIf wipeRoot {
            after = [ "initrd-root-device.target" ];
            before = [ "sysroot.mount" ];
            description = "Roll the root subvolume back to empty snapshot";

            script = ''
              if [ ! -b /dev/disk/by-label/nixos ]; then
                echo "No btrfs filesystem labeled 'nixos' found (e.g. running in test VM), skipping rollback."
                exit 0
              fi
              mkdir -p /mnt-btrfs
              mount -t btrfs -o subvol=/ /dev/disk/by-label/nixos /mnt-btrfs
              if [ -e /mnt-btrfs/root ]; then
                # Delete any nested subvolumes under root first
                btrfs subvolume list -o /mnt-btrfs/root | cut -f9 -d' ' | while read -r subvol; do
                  btrfs subvolume delete "/mnt-btrfs/$subvol"
                done
                btrfs subvolume delete /mnt-btrfs/root
              fi
              btrfs subvolume snapshot /mnt-btrfs/root-blank /mnt-btrfs/root
              umount /mnt-btrfs
            '';

            serviceConfig.Type = "oneshot";
            unitConfig.DefaultDependencies = "no";
            wantedBy = [ "initrd.target" ];
          };
        };
      };
  };

  # Ephemeral /tmp on tmpfs
  den.aspects.impermanence.tmpfs = {
    nixos = {
      boot.tmp = {
        cleanOnBoot = lib.mkDefault true;
        useTmpfs = lib.mkDefault true;
      };
    };
  };
}
