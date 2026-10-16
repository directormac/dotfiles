# Disko Btrfs Subvolume Layout Aspect
{
  lib,
  inputs,
  ...
}:
{
  den.aspects.disk.btrfs = {
    nixos =
      { ... }:
      {
        disko.devices.disk.main = {
          content = {
            partitions = {
              ESP = {
                content = {
                  format = "vfat";

                  mountOptions = [
                    "fmask=0077"
                    "dmask=0077"
                  ];

                  mountpoint = "/boot";
                  type = "filesystem";
                };

                priority = 1;
                size = "1G";
                type = "EF00";
              };

              root = {
                content = {
                  extraArgs = [
                    "-L"
                    "nixos"
                    "-f"
                  ];

                  postCreateHook = ''
                    mount -t btrfs /dev/disk/by-label/nixos /mnt
                    btrfs subvolume snapshot -r /mnt/root /mnt/root-blank
                    umount /mnt
                  '';

                  subvolumes = {
                    "/cache" = {
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];

                      mountpoint = "/cache";
                    };

                    "/home" = {
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];

                      mountpoint = "/home";
                    };

                    "/nix" = {
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];

                      mountpoint = "/nix";
                    };

                    "/persist" = {
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];

                      mountpoint = "/persist";
                    };

                    "/root" = {
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];

                      mountpoint = "/";
                    };
                  };

                  type = "btrfs";
                };

                priority = 3;
                size = "100%";
              };

              swap = {
                content = {
                  resumeDevice = false;
                  type = "swap";
                };

                priority = 2;
                size = "8G";
              };
            };

            type = "gpt";
          };

          device = lib.mkDefault "/dev/disk/by-uuid/dcd3cd20-f5d6-4bf9-8670-cdf6dfb7c923";
          type = "disk";
        };

        fileSystems."/cache".neededForBoot = true;
        fileSystems."/home".neededForBoot = true;
        fileSystems."/nix".neededForBoot = true;
        fileSystems."/persist".neededForBoot = true;
        imports = [ inputs.disko.nixosModules.disko ];
      };
  };
}
