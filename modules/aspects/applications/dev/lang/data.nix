# Structured Data & Config Formats (TOML, YAML, JSON) Aspect
{
  den.aspects.applications.dev.lang.data = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          taplo
          yaml-language-server
          yamlfmt
          vscode-json-languageserver
        ];
      };
  };

  flake.wrappers.neovim =
    { pkgs, ... }:
    {
      config.specs.data = {
        data = null;

        runtimePkgs = with pkgs; [
          taplo
          yaml-language-server
          yamlfmt
          vscode-json-languageserver
        ];
      };
    };
}
