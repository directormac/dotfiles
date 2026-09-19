{inputs, ...}: {
  imports = [
    inputs.files.flakeModules.default
    inputs.flake-parts.flakeModules.modules
  ];

  _module.args.dag = inputs.dag.lib {inherit (inputs.nixpkgs) lib;};

  flake-file.inputs.dag.url = "github:denful/dag";

  perSystem = {config, ...}: {
    devenv.shells.default.packages = [config.files.writer.drv];
    devenv.shells.default.scripts.write-files = {
      exec = "${config.files.writer.drv}/bin/write-files";
      description = "Generate files";
    };
    apps.write-files = {
      type = "app";
      program = "${config.files.writer.drv}/bin/write-files";
      # description = "Generate files";
    };
  };
}
