{ inputs, ... }: {
  flake-file.inputs = {
    dag.url = "github:denful/dag";
    files.url = "github:sini/files";

    # github-gitignore = {
    #   flake = false;
    #   url = "github:github/gitignore";
    # };
  };

  imports = [
    inputs.files.flakeModules.default
    inputs.flake-parts.flakeModules.modules
  ];

  _module.args.dag = inputs.dag.lib { inherit (inputs.nixpkgs) lib; };

  perSystem = { config, ... }: {

    apps.write-files = {
      program = "${config.files.writer.drv}/bin/write-files";
      type = "app";
      # description = "Generate files";
    };

    # devenv.shells.default.packages = [ config.files.writer.drv ];
    #
    # devenv.shells.default.scripts.write-files = {
    #   description = "Generate files";
    #   exec = "${config.files.writer.drv}/bin/write-files";
    # };
  };

  # perSystem = { config, ... }: {
  #   apps.write-files = {
  #     program = "${config.files.writer.drv}/bin/write-files";
  #     type = "app";
  #   };
  #
  #   devshells.default.commands = [
  #     {
  #       package = config.files.writer.drv;
  #       help = "Generate files";
  #     }
  #   ];
  #
  #   devshells.default.packages = [ config.files.writer.drv ];
  # };
}
# {
#   config,
#   lib,
#   flake-parts-lib,
#   ...
# }:
# let
#   extensionOf =
#     name:
#     let
#       parts = lib.splitString "." name;
#     in
#     if builtins.length parts > 1 then lib.last parts else "";
#   outerCfg = config.files;
# in
# {
#   options.files.warning = {
#     formatters = lib.mkOption {
#       default =
#         let
#           hashSign =
#             text:
#             (
#               # lib.splitString "\n" text
#               # |> lib.concatMapStringsSep "\n" (line:
#               #   if line == ""
#               #   then ""
#               #   else "# ${line}")
#               lib.pipe text [
#                 (lib.splitString "\n")
#                 (lib.concatMapStringsSep "\n" (line: if line == "" then "" else "# ${line}"))
#               ]
#             );
#         in
#         {
#           envrc = hashSign;
#           gitignore = hashSign;
#           license = _: "";
#           md = text: "<!-- ${text} -->\n";
#           nix = hashSign;
#           sh = hashSign;
#           toml = hashSign;
#         };
#
#       description = "Functions to format comments for different file types.";
#       readOnly = true;
#       type = lib.types.attrsOf (lib.types.functionTo lib.types.str);
#     };
#
#     text = lib.mkOption {
#       default = ''
#         DO-NOT-EDIT.
#         This file was auto-generated using github:sini/files.
#         Use `nix run .#write-files` to regenerate it.
#       '';
#
#       description = "Text to include in the generated comment at the top of generated files.";
#       type = lib.types.str;
#     };
#   };
#
#   options.perSystem = flake-parts-lib.mkPerSystemOption (
#     { lib, ... }: {
#       options.files.warning = {
#         # No file type needed for the common case: it's inferred from the file's own name (".gitignore" -> "gitignore",
#         #  "README.md" -> "md", ...).
#         # Only files whose name doesn't carry its own type (e.g. ".intellishell") need `formatAs "sh"` instead.
#         format = lib.mkOption {
#           description = ''
#             `files.file.<name>.format` function that prepends the generated-warning comment
#             (inferring the comment style from `name`'s own extension) and reformats via
#             treefmt. Leave a file's `format` unset to skip the warning entirely.
#           '';
#
#           readOnly = true;
#           type = lib.types.functionTo (lib.types.functionTo lib.types.package);
#         };
#
#         formatAs = lib.mkOption {
#           description = ''
#             Like `files.warning.format`, but for files whose name doesn't carry a usable
#             type, e.g. `format = config.files.warning.formatAs "sh";`.
#           '';
#
#           readOnly = true;
#           type = lib.types.functionTo (lib.types.functionTo (lib.types.functionTo lib.types.package));
#         };
#       };
#     }
#   );
#
#   config.perSystem =
#     {
#       config,
#       lib,
#       pkgs,
#       self',
#       ...
#     }:
#     {
#       apps.generate-files =
#         let
#           description = "Generate all automatically generated files for this repository";
#         in
#         {
#           program = pkgs.writeShellApplication {
#             name = "generate-files";
#
#             text = ''
#               # github:sini/files.
#               ${self'.apps.write-files.program}
#
#               lock_bck=$(mktemp)
#               cp -p flake.lock "$lock_bck"
#
#               ${lib.getExe self'.packages.write-flake}
#
#               # If flake.lock remains unchanged, restore mtime.
#               if cmp -s flake.lock "$lock_bck"; then
#                 touch -r "$lock_bck" flake.lock
#               fi
#             '';
#
#             meta.description = description;
#           };
#
#           meta.decription = description;
#         };
#
#       files.generateApp = true;
#       files.treefmt.enable = true;
#
#       # `files.treefmt.enable` and `files.warning.format`/`formatAs` both invoke treefmt on
#       # files that live outside the actual git worktree (they run inside the Nix sandbox), so
#       # treefmt's usual upward search for `config.treefmt.projectRootFile` (`.git/config`)
#       # can't find a tree root there. Point it at the file being formatted instead.
#       files.treefmt.package = pkgs.writeShellScriptBin "treefmt-tree-root-file" ''
#         exec ${lib.getExe config.formatter} --tree-root-file "''${@: -1}" "$@"
#       '';
#
#       files.warning.format = name: config.files.warning.formatAs (extensionOf name) name;
#
#       files.warning.formatAs =
#         fileType: name: drv:
#         let
#           comment = if mkComment == null then "" else mkComment outerCfg.warning.text;
#           escapedName = lib.escapeShellArg name;
#           mkComment = outerCfg.warning.formatters.${fileType} or null;
#         in
#         pkgs.runCommandLocal "warned-${builtins.replaceStrings [ "/" ] [ "-" ] name}" { inherit comment; }
#           ''
#             mkdir -p "$(dirname ${escapedName})"
#             touch ${escapedName}
#             if [ -n "$comment" ]; then
#               echo "$comment" >> ${escapedName}
#             fi
#             cat ${drv} >> ${escapedName}
#             ${lib.getExe config.files.treefmt.package} --no-cache ${escapedName}
#             mv ${escapedName} $out
#           '';
#
#       # https://github.com/vidhanio/vidhanix/blob/62305aa1a355b2519ab4449a3cf38334ccafbc89/modules/files/default.nix
#       # pre-commit.settings.hooks.generate-files = {
#       #   enable = true;
#       #   package = config.packages.generate-files;
#       #   entry = self'.apps.generate-files.program;
#       #   pass_filenames = false;
#       # };
#       # files.readme.content.generated-files.content = ''
#       #   most of the non-nix files in this repository (including this very readme) are generated via [`nix run .#generate-files`](modules/files/default.nix).
#       #   the generated files are:
#       #   ${config.files.readme.lib.renderList (
#       #     map (p: "[`${p}`](${p})") (lib.sortOn (p: p) (map ({ path_, ... }: path_) config.files.files))
#       #   )}
#       # '';
#     };
# }
