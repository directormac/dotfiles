# Tmux Neovim Integration
#
# Tree-sitter grammar and language server for tmux configuration files.
#
# The grammar is not shipped by nixpkgs, so it is built here and exposed to
# the neovim wrapper (see `modules/aspects/applications/dev/editor/neovim.nix`,
# which installs the plugin). It powers:
#   * syntax highlighting for `*.tmux.conf` files
#   * `# tmux` injections inside Nix files (see `_config.nix` and
#     `_plugins.nix`), which keep `conform` from feeding tmux configuration
#     to `shfmt`
{
  lib,
  inputs,
  ...
}:
{ pkgs, ... }:
let
  freedWu =
    if pkgs ? nur && pkgs.nur ? repos && pkgs.nur.repos ? Freed-Wu then
      pkgs.nur.repos.Freed-Wu
    else
      inputs.nur.legacyPackages.${pkgs.stdenv.hostPlatform.system}.repos.Freed-Wu;
  lsp-tree-sitter = relaxUvBuild freedWu.lsp-tree-sitter;
  relaxUvBuild =
    pkg:
    pkg.overridePythonAttrs (old: {
      pypaBuildFlags = lib.unique ((old.pypaBuildFlags or [ ]) ++ [ "--skip-dependency-check" ]);
    });
  tmux-language-server = (relaxUvBuild freedWu.tmux-language-server).overridePythonAttrs (old: {
    propagatedBuildInputs = map (
      dep: if (dep.pname or "") == "lsp-tree-sitter" then lsp-tree-sitter else dep
    ) (old.propagatedBuildInputs or [ ]);
  });
in
{
  config.specs.tmux = {
    data = null;

    runtimePkgs = lib.optionals (inputs ? nur) [
      tmux-language-server
    ];
  };
}
