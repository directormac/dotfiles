# Vivid LS_COLORS Generator Aspect
{ den, ... }:
{
  den.aspects.applications.dev.shell.vivid = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.vivid ];

        programs.vivid = {
          enable = true;
          enableZshIntegration = true;
          enableBashIntegration = true;
          activeTheme = "catppuccin-mocha";
          colorMode = "24-bit";
        };
      };
  };
}
