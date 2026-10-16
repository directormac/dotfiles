{
  config,
  den,
  ...
}:
let
  inherit (den.lib.policy) route;
in
{
  den.classes.formatter = {
    description = "Forwarder for aspect formatter configuration into flake-parts treefmt";
  };

  den.classes.treefmt = {
    description = "Alias for aspect formatter configuration into flake-parts treefmt";
  };

  den.policies.formatter-to-flake-parts = _: [
    (route {
      adaptArgs = { config, ... }: config.allModuleArgs;
      fromClass = "formatter";
      intoClass = "flake-parts";
      path = [ "treefmt" ];
    })
    (route {
      adaptArgs = { config, ... }: config.allModuleArgs;
      fromClass = "treefmt";
      intoClass = "flake-parts";
      path = [ "treefmt" ];
    })
  ];

  den.schema.flake-parts.includes = [ config.den.policies.formatter-to-flake-parts ];
}
