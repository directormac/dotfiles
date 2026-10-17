{ den, inputs, ... }:
{
  den.aspects.impermanence = {
    includes = [
      den.aspects.impermanence.collect
      den.aspects.impermanence.rollback-btrfs
    ];

    nixos = {
      environment.persistence."/cache" = {
        directories = [
          "/var/tmp"
        ];

        hideMounts = true;
      };

      environment.persistence."/persist" = {
        directories = [
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
        ];

        files = [
          "/etc/machine-id"
          "/etc/adjtime"
          "/var/lib/systemd/credential.secret"
        ];

        hideMounts = true;
      };

      imports = [ inputs.impermanence.nixosModules.impermanence ];
      # Allow users to mount persistent bind mounts with fuse
      programs.fuse.userAllowOther = true;
    };

    cacheHome.directories = [
      "Downloads"
      ".local/share/nix"
    ];

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
      ".dotfiles"
      "Work"
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
        merge = entries: {
          directories = lib.unique (lib.concatMap (e: e.directories or [ ]) entries);
          files = lib.unique (lib.concatMap (e: e.files or [ ]) entries);
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
        merge = entries: {
          directories = lib.unique (lib.concatMap (e: e.directories or [ ]) entries);
          files = lib.unique (lib.concatMap (e: e.files or [ ]) entries);
        };
      in
      {
        home.persistence."/cache" = merge cacheHome;
        home.persistence."/persist" = merge persistHome;
      };
  };

  # Btrfs rollback aspect: wipes ephemeral root and restores root-blank snapshot on early boot
  den.aspects.impermanence.rollback-btrfs = {
    nixos = {
      boot.initrd.systemd.services.rollback-root = {
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
}
