{ inputs, ... }: {
  flake-file.inputs.flake-root.url = "github:srid/flake-root";

  # flake-file.inputs.flake-root.url = "https://github.com/srid/flake-root/archive/refs/tags/v0.1.0.tar.gz";

  imports = [
    inputs.flake-root.flakeModule
  ];

  _module.args.rootPath = ../..;

  perSystem = { config, ... }: {
    devenv.shells.default.packages = [ config.flake-root.package ];
    flake-root.projectRootFile = "flake.nix";
  };
}
