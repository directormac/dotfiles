{
  config,
  den,
  ...
}:
let
  inherit (den.lib.policy) route;
in
{
  den.classes.devenv = {
    description = "Forwarder for aspect devenv configuration into flake-parts devenv default shell";
  };

  den.policies.devenv-to-flake-parts = _: [
    (route {
      adaptArgs = { config, ... }: config.allModuleArgs;
      fromClass = "devenv";
      intoClass = "flake-parts";

      path = [
        "devenv"
        "shells"
        "default"
      ];
    })
  ];

  den.schema.flake-parts.includes = [ config.den.policies.devenv-to-flake-parts ];
}
