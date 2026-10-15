# Zoxide Smart cd Aspect
{
  den.aspects.applications.dev.shell.zoxide = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.zoxide ];

        programs.zoxide = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };
      };

    persistHome.directories = [
      ".local/share/zoxide"
    ];
  };
}
