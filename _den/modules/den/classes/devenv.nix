{
  den,
  inputs,
  ...
}: let
  inherit (den.lib.policy) route;
in {
  # flake-file.inputs = {
  #   devenv.url = "github:cachix/devenv";
  #   # We remove devenv-root from here, as you've fixed it in your perSystem config
  # };

  # Since your modules/flake-parts/devenv.nix already imports the flakeModule,
  # we only need to handle the class registration and routing here.
  den.classes.devenv = {};

  den.policies.devenv-to-flake-parts = _: [
    (route {
      fromClass = "devenv";
      intoClass = "flake-parts";
      path = ["devenv" "shells" "default"];
      adaptArgs = {config, ...}: config.allModuleArgs;
    })
  ];

  # Enter flake-parts scope from flake-system
  den.schema.flake-system.includes = [den.policies.system-to-flake-parts];

  den.schema.flake-parts.includes = [
    den.policies.devenv-to-flake-parts
  ];
}
