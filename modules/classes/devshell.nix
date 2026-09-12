{
  den,
  inputs,
  ...
}: let
  inherit (den.lib.policy) route;
in {
  flake-file.inputs = {
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [inputs.devshell.flakeModule];
  den.classes.devshell = {};
  den.policies.devshell-to-flake-parts = _: [
    (route {
      fromClass = "devshell";
      intoClass = "flake-parts";
      path = [
        "devshells"
        "default"
      ];
      adaptArgs = {config, ...}: config.allModuleArgs;
    })
  ];
  den.schema.flake-parts.includes = [den.policies.devshell-to-flake-parts];
}
