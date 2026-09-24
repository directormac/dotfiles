{ den, ... }:
let
  treefmt =
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
      fromClass = _: "treefmt";
      intoClass = _: "flake-parts";
      intoPath = _: [ "treefmt" ];
    };
in
{
  den.schema.flake-parts.includes = [ treefmt ];
}
