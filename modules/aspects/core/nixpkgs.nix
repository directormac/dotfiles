# Core Nixpkgs Aspect: Unfree, Local & Stable Overlays, and Aspect Overlays Collector
{
  inputs,
  withSystem,
  ...
}:
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

    nixpkgs-overlays = _: [
      # Local packages as pkgs.local
      (final: _prev: {
        local = withSystem final.stdenv.hostPlatform.system ({ config, ... }: config.packages);
      })
      # Stable packages as pkgs.stable
      (final: _prev: {
        stable = import inputs.nixpkgs-stable {
          inherit (final.stdenv.hostPlatform) system;
          config.allowUnfree = true;
        };
      })
    ];
  };
}
