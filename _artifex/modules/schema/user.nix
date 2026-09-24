{
  lib,
  rootPath,
  ...
}:
let
  inherit (lib) mkOption types;

  sshKeyType = types.submodule {
    options = {
      key = mkOption {
        description = "SSH public key string";
        type = types.str;
      };

      tag = mkOption {
        default = null;
        description = "Tag to categorize the SSH key (e.g., 'laptop', 'workstation', 'yubikey')";
        type = types.nullOr types.str;
      };
    };
  };
in
{
  den.schema.user.classes = lib.mkDefault [
    "homeManager"
  ];

  /**
    [Schema Submodule](https://den.denful.dev/guides/configure-aspects/#aspect-custom-submodule)
  */
  den.schema.user.imports = [
    ({ config, ... }: {
      options = {
        identity = mkOption {
          default = { };
          description = "User identity information";

          type = types.submodule (_: {
            options = {
              displayName = mkOption {
                default = "";
                description = "Display name for the user";
                type = types.str;
              };

              email = mkOption {
                default = null;
                description = "Email address for the user";
                type = types.nullOr types.str;
              };

              gpgKey = mkOption {
                default = null;
                description = "GPG key ID for the user";
                type = types.nullOr types.str;
              };

              sshKeys = mkOption {
                default = [ ];
                description = "SSH public keys for the user, each with an optional tag";
                type = types.listOf sshKeyType;
              };
            };
          });
        };

        secretPath = mkOption {
          # rootPath (a plain `../..` path literal), NOT `self`: this default is
          # forced during the base registry eval, where `self` self-cycles
          # (registry → self → flake outputs → registry). Matches the existing
          # per-user secret convention (spotify-player, agenixUserAspect).
          default = rootPath + "/.secrets/users/${config.name}";
          description = "Per-user secret directory (mirrors host/environment/cluster secretPath).";
          type = types.path;
        };

        system = mkOption {
          type = types.submodule (_: {
            options = {
              settings = mkOption {
                default = { };
                description = "Per-user feature settings (freeform nested namespace)";
                type = types.attrsOf (types.attrsOf types.anything);
              };

              excluded-features = mkOption {
                default = [ ];
                description = "Feature aspects to exclude for this user";
                type = types.listOf types.str;
              };

              extra-features = mkOption {
                default = [ ];
                description = "Additional feature aspects to include for this user beyond defaults";
                type = types.listOf types.str;
              };

              include-host-features = mkOption {
                default = false;
                description = "Whether to inherit host-level aspect features for this user";
                type = types.bool;
              };

              linger = mkOption {
                default = false;
                description = "Enable lingering for the user (systemd user services start without login)";
                type = types.bool;
              };
            };
          });
        };
      };
    })
  ];
}
