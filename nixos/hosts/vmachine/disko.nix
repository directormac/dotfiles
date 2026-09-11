{
  flake.diskoConfigurations.vmachine = {
    disko.devices = {
      disk = {
        main = {
          device = "/dev/vda";
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                size = "1M";
                type = "EF02"; # for grub MBR
              };
              ESP = {
                name = "ESP";
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = ["umask=0077"];
                };
              };
              root = {
                name = "root";
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
      # nodev = {
      #   "/tmp" = {
      #     fsType = "tmpfs";
      #     mountOptions = [
      #       "size=25%"
      #       "mode=755"
      #     ];
      #   };
      # };
    };

    # Tell systemd these mounts must be ready early in boot.
    # /persist holds machine-id, ssh host keys, and sops keys — without
    # this flag, services that need them at boot will fail.
    # fileSystems."/persist".neededForBoot = true;
  };
}
