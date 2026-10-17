# Zoxide Smart cd Aspect
{
  den.aspects.applications.dev.shell.zoxide = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.zoxide ];

        home.sessionVariables = {
          _ZO_EXCLUDE_DIRS = "$HOME:$HOME/Code/.worktrees/*:$HOME/Code/.worktrees";
        };

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
