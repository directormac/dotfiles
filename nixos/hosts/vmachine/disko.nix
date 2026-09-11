{
  flake.diskoConfigurations.vmachine = {
    disko.devices = {
      disk.main = {
        device = "/dev/disk/by-id/a941fa4e-9d94-4b76-b46c-8f07fd048373";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              size = "1M";
              type = "EF02";
            };
            esp = {
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              name = "root";
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "btrfs_vg";
              };
            };
          };
        };
      };

      # Tell systemd these mounts must be ready early in boot.
      # /persist holds machine-id, ssh host keys, and sops keys — without
      # this flag, services that need them at boot will fail.
      fileSystems."/persist".neededForBoot = true;

      nodev = {
        "/" = {
          fsType = "tmpfs";
          mountOptions = [
            "size=25%"
            "mode=755"
          ];
        };
      };

      lvm_vg = {
        btrfs_vg = {
          type = "lvm_vg";
          lvs = {
            root = {
              size = "100%FREE";
              content = {
                type = "btrfs";
                extraArgs = ["-f"];

                subvolumes = {
                  "/root" = {
                    # mountpoint = "/";
                  };

                  "/persist" = {
                    mountOptions = ["subvol=persist" "noatime"];
                    mountpoint = "/persist";
                  };

                  "/nix" = {
                    mountOptions = ["subvol=nix" "noatime"];
                    mountpoint = "/nix";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
