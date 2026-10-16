# GitHub CLI Aspect
{
  den.aspects.applications.dev.git.github = {
    homeManager =
      { pkgs, ... }:
      {
        programs.gh = {
          settings.git_protocol = "ssh";
          enable = true;

          extensions = with pkgs; [
            gh-dash
            gh-f
            gh-s
            gh-stack
            gh-markdown-preview
          ];
        };
      };

    persistHome.directories = [
      ".config/gh"
    ];
  };
}
