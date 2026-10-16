{
  config,
  den,
  ...
}:
let
  inherit (den.lib.policy) route;
in
{
  den.classes.files = {
    description = "Forwarder for aspect files into flake-parts files";
  };

  den.policies.files-to-flake-parts = _: [
    (route {
      adaptArgs = { config, ... }: config.allModuleArgs;
      fromClass = "files";
      intoClass = "flake-parts";
      path = [ "files" ];
    })
  ];

  den.schema.flake-parts.includes = [ config.den.policies.files-to-flake-parts ];
}
