# Core Nixpkgs Aspect: Unfree, Local & Stable Overlays, and Aspect Overlays Collector
{
  den,
  inputs,
  withSystem,
  ...
}:
{
  den.aspects.core.nixpkgs = {
    nixpkgs-overlays = _: [
      # Local packages as pkgs.local
      (
        final: _prev: {
          local = withSystem final.stdenv.hostPlatform.system ({ config, ... }: config.packages);
        }
      )
      # Stable packages as pkgs.stable
      (
        final: _prev: {
          stable = import inputs.nixpkgs-stable {
            inherit (final.stdenv.hostPlatform) system;
            config.allowUnfree = true;
          };
        }
      )
    ];

    nixos =
      { nixpkgs-overlays, lib, ... }:
      {
        nixpkgs = {
          config.allowUnfree = lib.mkDefault true;
          overlays = lib.unique nixpkgs-overlays;
        };
      };
  };
}
