# Markdown Language & Tooling Aspect
{
  den.aspects.applications.dev.lang.markdown = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          marksman
          markdownlint-cli2
        ];
      };
  };

  flake.wrappers.neovim =
    { pkgs, ... }:
    {
      config.specs.markdown = {
        data = null;

        runtimePkgs = with pkgs; [
          marksman
          markdownlint-cli2
        ];
      };
    };
}
