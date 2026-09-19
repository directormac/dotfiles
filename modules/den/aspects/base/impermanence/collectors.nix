{ den, lib, ... }:
{
  den.aspects.base.impermanence.persist-collector = {
    nixos =
      {
        persist,
        cache,
        lib,
        ...
      }:
      let
        mergePersist = entries: {
          directories = lib.unique (lib.concatMap (e: e.directories or [ ]) entries);
          files = lib.unique (lib.concatMap (e: e.files or [ ]) entries);
        };
      in
      {
        # impermanence NixOS module imported by disk.impermanence aspect
        environment.persistence."/persist" = mergePersist persist;
        environment.persistence."/cache" = mergePersist cache;
      };
  };

  den.aspects.base.impermanence.persist-home-collector = {
    homeManager =
      {
        persistHome,
        cacheHome,
        lib,
        ...
      }:
      let
        mergePersist = entries: {
          directories = lib.unique (lib.concatMap (e: e.directories or [ ]) entries);
          files = lib.unique (lib.concatMap (e: e.files or [ ]) entries);
        };
      in
      {
        home.persistence."/persist" = mergePersist persistHome;
        home.persistence."/cache" = mergePersist cacheHome;
      };
  };
}
