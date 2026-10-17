# Lumen - https://github.com/jnsahaj/lumen
{
  den.aspects.applications.dev.shell.lumen = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          lumen
        ];

        home.sessionVariables = {
          LUMEN_AI_PROVIDER = "";
          LUMEN_API_KEY = "";
          LUMEN_API_MODEL = "";
        };
      };
  };
}
