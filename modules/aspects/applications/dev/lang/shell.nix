# Shell Scripting & Bash Language Aspect
{
  den.aspects.applications.dev.lang.shell = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          bash-language-server
          shfmt
          shellcheck
        ];
      };
  };

  flake.wrappers.neovim =
    { pkgs, ... }:
    {
      config.specs.shell = {
        data = null;

        runtimePkgs = with pkgs; [
          bash-language-server
          shfmt
          shellcheck
        ];
      };
    };
}
