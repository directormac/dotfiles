{
  den,
  inputs,
  ...
}: let
  inherit (den.lib.policy) route;
in {
  flake-file.inputs = {
    files.url = "github:sini/files";
  };

  # Note: modules/flake-parts/files.nix already imports inputs.files.flakeModules.default
  # so we don't need to duplicate the import here.
  den.classes.files = {};

  den.policies.files-to-flake-parts = _: [
    (route {
      fromClass = "files";
      intoClass = "flake-parts";
      path = ["files"];
      adaptArgs = {config, ...}: config.allModuleArgs;
    })
  ];

  den.schema.flake-parts.includes = [den.policies.files-to-flake-parts];
}
