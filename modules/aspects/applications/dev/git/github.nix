# GitHub CLI Aspect
{ den, ... }:
{
  den.aspects.applications.dev.git.github = {
    homeManager =
      { pkgs, ... }:
      {
        programs.gh = {
          enable = true;
          settings.git_protocol = "ssh";

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
