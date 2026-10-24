# lazyrsync - https://github.com/westpoint-io/lazyrsync
{
  den.aspects.applications.dev.shell.lazyrsync = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          (pkgs.local.lazyrsync or pkgs.lazyrsync)
          # lazyrsync shells out to rsync for every run
          pkgs.rsync
        ];
      };

    # profiles.toml and settings.toml are user-authored, not regenerable
    persistHome.directories = [ ".config/lazyrsync" ];
  };
}
