# Nix Developer Tools Aspect
{
  lib,
  inputs,
  ...
}:
{

  flake-file = {
    inputs = {
      nixfmt-rs.url = "github:Mic92/nixfmt-rs";
      pedantix.url = "github:swarsel/pedantix";
    };
  };

  den.aspects.applications.dev.lang.nix = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          manix
          nix-prefetch-scripts
          nix-prefetch-github
          nix-tree

          nil
          nixd
          nixfmt
          statix
          alejandra
        ];
      };

    homeManager = {
      imports = lib.optionals (inputs ? pedantix) [
        inputs.pedantix.homeModules.default
      ];

      programs.pedantix = {
        settings = {
          lets.sort = true;
          preset = "nixos-module";
        };

        enable = true;
      };
    };
  };

  flake.wrappers.neovim =
    { pkgs, ... }:
    {
      config.specs.nix = {
        data = null;

        runtimePkgs = with pkgs; [
          nixd
          nil
          nixfmt
          statix
        ];
      };
    };
}
