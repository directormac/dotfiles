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
{
  config.specs.tmux = {
    data = null;

    runtimePkgs = lib.optionals (inputs ? nur) [
      inputs.nur.legacyPackages.${pkgs.stdenv.hostPlatform.system}.repos.Freed-Wu.tmux-language-server
    ];
  };
}
