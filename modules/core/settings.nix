# Aspect Settings Integration: attaches typed settings to host and user entities.
{ lib, den, ... }:
{
  # 1. Reserve the "settings" key in Den
  den.reservedKeys = [ "settings" ];

  # 2. Attach settings options to host schema
  den.schema.host.imports = [
    {
      options.settings = lib.mkOption {
        default = { };
        description = "Per-aspect typed settings for hosts";
        type = import ./_settings-type.nix { inherit den lib; };
      };
    }
  ];

  # 3. Attach settings and dotsConfigPath to user schema
  den.schema.user.imports = [
    (
      { user, ... }:
      {
        options.dotsConfigPath = lib.mkOption {
          default = "/home/${user.name}/.dotfiles/config";
          description = "Absolute path to the live dotfiles config/ directory for out-of-store symlinks.";
          type = lib.types.str;
        };

        options.secretPath = lib.mkOption {
          default = ../.. + "/.secrets/users/${user.name}";
          description = "Per-user secret directory.";
          type = lib.types.path;
        };

        options.settings = lib.mkOption {
          default = { };
          description = "Per-aspect typed settings for users";
          type = import ./_settings-type.nix { inherit den lib; };
        };
      }
    )
  ];
}
