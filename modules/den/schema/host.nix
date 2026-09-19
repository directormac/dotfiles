# Host entity schema — channels, networking, settings, computed fields.
#
# Follows feat/den's approach: channels defined inline, instantiate/HM module
# derived from config.channel, dynamic settings namespace from den.aspects,
# computed ipv4/ipv6 from networking interfaces.
{
  lib,
  inputs,
  den,
  self,
  rootPath,
  ...
}: let
  inherit (lib) mkOption types;
  schemaLib = inputs.gen-schema.lib;

  # Dynamic settings type — recursively discovers aspects that declare .settings.
  # Mirrors the aspect tree: den.aspects.disk.zfs-disk-single.settings →
  # host.settings.disk.zfs-disk-single.*  (shared with the cluster schema).
  settingsType = import ./_settings-type.nix {inherit den lib;};
in {
  den.schema.host.isEntity = true;

  den.schema.host.imports = [
    (
      {config, ...}: {
        options = {
          # environment = mkOption {
          #   type = types.str;
          #   default = "prod";
          #   description = "Environment name that this host belongs to";
          # };

          system-owner = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Primary user for this host";
          };

          system-access-groups = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Groups granting Unix account creation on this host";
          };

          # facts =
          #   mkOption {
          #     type = types.nullOr types.path;
          #     default = null;
          #   }
          #   // {
          #     identity = false;
          #   };

          secretPath =
            mkOption {
              type = types.nullOr types.path;
              default = null;
            }
            // {
              identity = false;
            };

          public_key =
            mkOption {
              type = types.nullOr types.path;
              default = null;
            }
            // {
              identity = false;
            };

          # Dynamic settings namespace — auto-discovers aspects with .settings
          settings =
            mkOption {
              type = settingsType;
              default = {};
              description = "Per-aspect typed settings";
            }
            // {
              identity = false;
            };
        };

        # Computed config — channel determines instantiate + HM module
        config = {
          # rootPath (a `../..` path literal), NOT `self`: these defaults are
          # forced during base eval by the producer-class config-thunk broadcast
          # (a host config is navigated to reach a nested home config), where
          # `self` self-cycles (registry → self → flake outputs → registry).
          # Same git-tracked source as `self`; mirrors `user.secretPath`.
          secretPath = lib.mkDefault (rootPath + "/.secrets/hosts/${config.name}");
          # facts = lib.mkDefault (rootPath + "/hosts/${config.name}/facter.json");
          public_key = lib.mkDefault (
            if config.secretPath != null
            then config.secretPath + "/ssh_host_ed25519_key.pub"
            else null
          );

          instantiate = inputs.nixpkgs.lib.nixosSystem;

          home-manager.module = inputs.home-manager.nixosModules.home-manager;
        };
      }
    )
  ];
}
