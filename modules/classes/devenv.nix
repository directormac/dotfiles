{ den, ... }:
let
  devenv =
    {
      lib,
      aspect-chain,
      class,
      ...
    }:
    den.batteries.forward {
      adaptArgs = { config, ... }: config.allModuleArgs;
      each = lib.singleton class;
      fromAspect = _: lib.last aspect-chain;
      fromClass = _: "devenv";
      intoClass = _: "flake-parts";

      intoPath = _: [
        "devenv"
        "shells"
        "default"
      ];
    };
in
{
  den.classes.devenv = {
    description = "Forwarder for /cache (host: environment.persistence, user: home.persistence)";
  };

  den.schema.flake-parts.includes = [ devenv ];

}
