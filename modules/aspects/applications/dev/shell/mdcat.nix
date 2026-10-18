{
  den.aspects.applications.dev.shell.mdcat = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          mdcat
        ];
      };
  };
}
