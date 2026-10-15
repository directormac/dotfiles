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
    (inputs.files.flakeModules.default or { })
    (inputs.flake-parts.flakeModules.modules or { })
  ];

  _module.args.dag = if inputs ? dag then inputs.dag.lib { inherit (inputs.nixpkgs) lib; } else { };

  perSystem =
    { config, lib, ... }:
    lib.optionalAttrs (inputs ? files) {

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
