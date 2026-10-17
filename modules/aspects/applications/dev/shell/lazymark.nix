{
  den.aspects.applications.dev.shell.lazymark = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          (pkgs.local.lazymark or pkgs.lazymark)
        ];
      };
  };
}
