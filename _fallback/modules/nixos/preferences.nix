{
  flake.nixosModules.base = { lib, ... }: {
    options.preferences = {
      user.name = lib.mkOption {
        type = lib.types.str;
        default = "artifex";
      };

      autostart = lib.mkOption {
        type = lib.types.listOf (lib.types.either lib.types.str lib.types.package);
        default = [ ];
      };

      keymap = lib.mkOption {
        type = lib.types.lazyAttrsOf (lib.types.either lib.types.attrs lib.types.package);
        default = { };
        example = {
          "SUPER + d" = {
            "f" = {
              exec = "firefox";
            };
          };
        };

      };

      options.persistance = {
        enable = lib.mkEnableOption "enable persistance";

        nukeRoot.enable = lib.mkEnableOption "Destroy /root on every boot";

        volumeGroup = lib.mkOption {
          default = "btrfs_vg";
          description = ''
            Btrfs volume group name
          '';
        };

        user = lib.mkOption {
          default = "username";
          description = ''
            Main user
          '';
        };

        directories = lib.mkOption {
          default = [ ];
          description = ''
            directories to persist
          '';
        };

        files = lib.mkOption {
          default = [ ];
          description = ''
            files to persist
          '';
        };

        data.directories = lib.mkOption {
          default = [ ];
          description = ''
            directories to persist
          '';
        };

        data.files = lib.mkOption {
          default = [ ];
          description = ''
            files to persist
          '';
        };

        cache.directories = lib.mkOption {
          default = [ ];
          description = ''
            directories to persist
          '';
        };

        cache.files = lib.mkOption {
          default = [ ];
          description = ''
            files to persist
          '';
        };
      };

    };
  };
}
