{ lib, ... }:
let
  inherit (lib) mkOption types;
  defaultBranch = "main";
  flakeUri = "git+https://github.com/${owner}/${name}?shallow=1";
  forge = "github";
  name = "dotfiles";
  owner = "directormac";
in
{
  options.flake.meta = mkOption {
    description = "Flake-level metadata.";
    type = types.lazyAttrsOf types.anything;
  };

  config.flake.meta = {
    repo = {
      inherit
        forge
        owner
        name
        defaultBranch
        flakeUri
        ;
    };

    uri = "github:directormac/dotfiles";
  };
}
