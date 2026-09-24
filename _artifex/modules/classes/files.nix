{ den, ... }:
let
  files =
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
      fromClass = _: "files";
      intoClass = _: "flake-parts";
      intoPath = _: [ "files" ];
    };
in
{
  den.schema.flake-parts.includes = [ files ];
}
