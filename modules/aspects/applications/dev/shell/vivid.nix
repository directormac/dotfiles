# Vivid LS_COLORS Generator Aspect
{
  den.aspects.applications.dev.shell.vivid = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.vivid ];

        programs.vivid = {
          activeTheme = "catppuccin-mocha";
          colorMode = "24-bit";
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };
      };
  };
}
