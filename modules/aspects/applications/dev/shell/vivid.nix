# Vivid LS_COLORS Generator Aspect
{
  den.aspects.applications.dev.shell.vivid = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.vivid ];

        programs.vivid = {
          enable = true;
          activeTheme = "catppuccin-mocha";
          colorMode = "24-bit";
          enableBashIntegration = true;
          enableZshIntegration = true;
        };
      };
  };
}
