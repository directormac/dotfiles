# _settings-type.nix: Generator for per-aspect typed settings.
# Leading underscore prevents import-tree from auto-importing it directly.
{ lib, den }:
let
  inherit (lib) mkOption types;
  inherit (den.lib.aspects.fx.keyClassification) isStructuralKey;
  # Support aspects defined in den.aspects as well as namespaced aspects in den.ful
  aspectsRoot = (den.aspects or { }) // (den.ful or { });
  hasSettingsDeep =
    node:
    builtins.isAttrs node
    && (
      node ? settings
      || lib.any (k: !(skipKey k) && hasSettingsDeep (node.${k} or null)) (builtins.attrNames node)
    );
  # One submodule per aspect-tree node. A node can carry its own settings
  # and also be the parent of aspects that do.
  nodeModule =
    node:
    let
      children = lib.filterAttrs (k: v: !(skipKey k) && builtins.isAttrs v && hasSettingsDeep v) node;
      own = reshape (node.settings or { });
    in
    {
      imports = own.imports or [ ];

      options =
        (own.options or { })
        // lib.mapAttrs (
          name: child:
          mkOption {
            default = { };
            description = "Settings under ${name}";
            type = types.submodule (nodeModule child);
          }
        ) children;

      config = own.config or { };
    };
  # `settings` is either a bare attrset of options, or a module with
  # options / config / imports.
  reshape = raw: if raw ? options || raw ? config || raw ? imports then raw else { options = raw; };
  # Keys that are pipeline machinery, class content, or quirk data,
  # never child aspects.
  skipKey = k: isStructuralKey k || (den.classes or { }) ? ${k} || (den.quirks or { }) ? ${k};
in
types.submodule (nodeModule aspectsRoot)
