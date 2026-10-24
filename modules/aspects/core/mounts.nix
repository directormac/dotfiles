# Core Filesystem Mounts (SMB Fileserver & Local NTFS Resources) Aspect
{
  den.aspects.core.mounts = {
    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        environment.systemPackages = with pkgs; [
          cifs-utils
          nfs-utils
          ntfs3g
          sshfs
          btrfs-progs
        ];

        fileSystems = lib.mkMerge [
          (lib.mkIf (config ? age && config.age.secrets ? fileserver-smb-secrets) {
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
            "/mnt/local/games" = {
              options = [
                "defaults"
                "nofail"
                "compress=zstd"
              ];

              device = "/dev/disk/by-uuid/03a50c42-e9e4-4770-8221-599d166f1ad1";
              fsType = "btrfs";
            };

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

        # Automatically create the game folders and assign them to your user
        systemd.tmpfiles.rules = [
          "d /mnt/local/games/steam 0755 artifex users -"
          "d /mnt/local/games/lutris 0755 artifex users -"
          "d /mnt/local/games/heroic 0755 artifex users -"
          "d /mnt/local/games/installers 0755 artifex users -"
        ];
      };
  };
}
# 03a50c42-e9e4-4770-8221-599d166f1ad1
