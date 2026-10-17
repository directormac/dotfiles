# Bat Cat Replacement Aspect
{
  den.aspects.applications.dev.shell.bat = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.bat ];

        programs.bat = {
          config = {
            italic-text = "always";

            map-syntax = [
              "*.ino:C++"
              ".ignore:Git Ignore"
            ];

            pager = "less --RAW-CONTROL-CHARS --quit-if-one-screen --mouse";
            paging = "auto";
            theme = "Catppuccin Mocha";
          };

          enable = true;
        };
      };
  };
}
