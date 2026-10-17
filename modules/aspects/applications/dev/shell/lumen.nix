# Lumen - https://github.com/jnsahaj/lumen
{
  den.aspects.applications.dev.shell.lumen = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          lumen
        ];
      };
  };
}
