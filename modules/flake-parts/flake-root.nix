{ inputs, ... }: {
  flake-file.inputs.flake-root.url = "github:srid/flake-root";

  # flake-file.inputs.flake-root.url = "https://github.com/srid/flake-root/archive/refs/tags/v0.1.0.tar.gz";

  imports = [
    (inputs.flake-root.flakeModule or { })
  ];

  _module.args.rootPath = ../..;

  perSystem =
    { config, lib, ... }:
    (lib.optionalAttrs (inputs ? devenv && inputs ? flake-root) {
      devenv.shells.default.packages = [ config.flake-root.package ];
    })
    // (lib.optionalAttrs (inputs ? flake-root) {
      flake-root.projectRootFile = "flake.nix";
    });
}
