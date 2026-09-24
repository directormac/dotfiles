{
  lib,
  den,
  rootPath,
  ...
}:
let
  inherit (lib) mkOption types;

  settingsType =
    let
      # Keys that are NOT child aspects: structural keys (includes, nixos, …),
      # plus your framework's registered class names and quirk/extension keys.
      # Adapt these three sources to your own framework.
      inherit (den.lib.aspects.fx.keyClassification) structuralKeysSet;
      classKeys = den.classes or { };
      # True if this node, or anything beneath it, declares settings.
      hasSettingsDeep =
        node:
        builtins.isAttrs node
        && (
          (node ? settings)
          || lib.any (k: !(skipKey k) && hasSettingsDeep (node.${k} or null)) (builtins.attrNames node)
        );
      # Build the submodule for one aspect-tree node, mirroring the tree.
      # Merge the node's OWN settings options with recursion into its
      # settings-bearing children.
      nodeModule =
        node:
        let
          childOptions = lib.mapAttrs (
            name: child:
            mkOption {
              default = { };
              description = "Settings under ${name}";
              type = types.submodule (nodeModule child);
            }
          ) settingChildren;
          ownConfig = ownSettings.config or { };
          # Distinct names again — keep statix from dropping the `or` default.
          ownImports = ownSettings.imports or [ ];
          ownSettings =
            if node ? settings then
              reshapeSettings node.settings
            else
              {
                imports = [ ];
                options = { };
                config = { };
              };
          settingChildren = lib.filterAttrs (
            k: v: !(skipKey k) && builtins.isAttrs v && hasSettingsDeep v
          ) node;
        in
        {
          imports = ownImports;
          options = (ownSettings.options or { }) // childOptions;
          config = ownConfig;
        };
      quirkKeys = den.quirks or { };
      # A settings block may be a plain options attrset ({ foo = mkOption {...}; })
      # OR module-shaped ({ imports; config; options; }). Normalize to the latter.
      reshapeSettings =
        raw:
        let
          config' = raw.config or { };
          # Bind to DISTINCT names on purpose — see the statix gotcha below.
          imports' = raw.imports or [ ];
        in
        {
          imports = imports';

          options = removeAttrs raw [
            "imports"
            "config"
          ];

          config = config';
        };
      skipKey = k: structuralKeysSet ? ${k} || classKeys ? ${k} || quirkKeys ? ${k};
    in
    types.submodule (nodeModule (den.aspects or { }));
  # ... other helpers: interfaceType, channel definitions, etc. ...
in
{
  den.reservedKeys = [ "settings" ];

  den.schema.host = { lib, ... }: {
    options.isWorkstation = lib.mkOption {
      default = true;
      description = "Whether this host is a workstation or not (e.g, a server).";
      type = lib.types.bool;
    };

    imports = [
      ({ config, ... }: {
        options = {
          # The generated, auto-discovered settings namespace:
          settings =
            mkOption {
              default = { };
              description = "Per-aspect typed settings";
              type = settingsType;
            }
            # Exclude settings from entity identity hashing.
            // {
              identity = false;
            };

          facts =
            mkOption {
              default = null;
              type = types.nullOr types.path;
            }
            // {
              identity = false;
            };

          public_key =
            mkOption {
              default = null;
              type = types.nullOr types.path;
            }
            // {
              identity = false;
            };

          secretPath =
            mkOption {
              default = null;
              type = types.nullOr types.path;
            }
            // {
              identity = false;
            };

          system-owner = mkOption {
            default = null;
            description = "Primary user for this host";
            type = types.nullOr types.str;
          };
        };

        # Computed config — channel determines instantiate + HM module
        config = {
          facts = lib.mkDefault (rootPath + "/hosts/${config.name}/facter.json");

          public_key = lib.mkDefault (
            if config.secretPath != null then config.secretPath + "/ssh_host_ed25519_key.pub" else null
          );

          # rootPath (a `../..` path literal), NOT `self`: these defaults are
          # forced during base eval by the producer-class config-thunk broadcast
          # (a host config is navigated to reach a nested home config), where
          # `self` self-cycles (registry → self → flake outputs → registry).
          # Same git-tracked source as `self`; mirrors `user.secretPath`.
          secretPath = lib.mkDefault (rootPath + "/.secrets/hosts/${config.name}");
        };
      })
    ];

    isEntity = true;
  };
}
