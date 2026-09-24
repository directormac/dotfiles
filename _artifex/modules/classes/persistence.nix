{
  lib,
  den,
  ...
}:
let
  cacheForward = mkPersistenceForward "cache";
  # Generic forwarder for persistence targets ("persist" or "cache")
  mkPersistenceForward =
    name:
    {
      aspect-chain,
      class,
      ...
    }:
    let
      isHome = class == "homeManager";
      prefix = if isHome then "home" else "environment";
    in
    den.batteries.forward {
      each = lib.singleton true;
      fromAspect = _item: lib.head aspect-chain;
      fromClass = _item: name;
      guard = { options, ... }: options ? ${prefix}.persistence;
      intoClass = _item: class;

      intoPath = _item: [
        prefix
        "persistence"
        "/${name}"
      ];
    };
  persistForward = mkPersistenceForward "persist";
in
{
  den.classes.cache = {
    description = "Forwarder for /cache (host: environment.persistence, user: home.persistence)";
  };

  den.classes.persist = {
    description = "Forwarder for /persist (host: environment.persistence, user: home.persistence)";
  };

  # Host aspects (NixOS)
  den.schema.host.includes = [
    persistForward
    cacheForward
  ];

  # User aspects (Home Manager)
  den.schema.user.includes = [
    persistForward
    cacheForward
  ];
}
