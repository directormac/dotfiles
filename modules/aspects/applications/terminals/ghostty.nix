# Ghostty Terminal Emulator Leaf Aspect
{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    ghostty = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:ghostty-org/ghostty";
    };
  };

  den.aspects.applications.terminals.ghostty = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.ghostty
        ];
      };

    homeManager =
      {
        config,
        user,
        ...
      }:
      let
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
      in
      {
        home.file.".config/ghostty" = {
          recursive = true;
          source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/ghostty";
        };

        home.file.".local/bin/gshader" = {
          executable = true;

          text = ''
            #!/usr/bin/env bash
            exec ${dotsPath}/ghostty/shader.sh "$@"
          '';
        };

        programs.ghostty = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          installBatSyntax = true;
          installVimSyntax = true;
        };
      };

    nixpkgs-overlays =
      _:
      lib.optional (
        inputs ? ghostty && inputs.ghostty ? overlays && inputs.ghostty.overlays ? default
      ) inputs.ghostty.overlays.default;
  };
}
