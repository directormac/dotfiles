# Core Nixpkgs Aspect: Unfree, Local & Stable Overlays, and Aspect Overlays Collector
{
  inputs,
  rootPath,
  withSystem,
  ...
}:
let
  sharedOverlays = builtins.attrValues (import (rootPath + "/pkgs/overlays.nix") { inherit inputs; });
in
{
  den.aspects.core.nixpkgs = {
    nixos =
      { lib, nixpkgs-overlays, ... }:
      {
        nixpkgs = {
          config.allowUnfree = lib.mkDefault true;
          overlays = lib.unique nixpkgs-overlays;
        };
      };

    nixpkgs-overlays =
      _:
      sharedOverlays
      ++ [
        # Local packages as pkgs.local
        (final: _prev: {
          local = withSystem final.stdenv.hostPlatform.system ({ config, ... }: config.packages);
        })
      ];
  };
}
