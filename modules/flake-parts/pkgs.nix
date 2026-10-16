{
  inputs,
  rootPath,
  withSystem,
  ...
}:
{
  flake-file.inputs = {
    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";

    zsh-histdb-src = {
      flake = false;
      url = "github:larkery/zsh-histdb";
    };
  };

  imports = [
    (inputs.pkgs-by-name-for-flake-parts.flakeModule or { })
  ];

  # local packages under pkgs.local; consumed by the den core.nixpkgs aspect
  flake.overlays.default =
    _final: prev:
    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }: {
        local = config.packages;
      }
    );

  perSystem =
    {
      lib,
      system,
      ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;

        config = {
          allowUnfree = true;
          # allowDeprecatedx86_64Darwin = true;
        };

        overlays = builtins.attrValues (import (rootPath + "/pkgs/overlays.nix") { inherit inputs; });
        # ++ [
        #   inputs.nix-topology.overlays.default
        # ];
      };
    }
    // (lib.optionalAttrs (inputs ? pkgs-by-name-for-flake-parts) {
      pkgsDirectory = rootPath + "/pkgs/by-name";
    });
}
