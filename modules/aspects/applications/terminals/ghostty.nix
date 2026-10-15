# Ghostty Terminal Emulator Leaf Aspect
{
  den,
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs = {
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  den.aspects.applications.terminals.ghostty = {
    nixpkgs-overlays = _: lib.optional (inputs ? ghostty && inputs.ghostty ? overlays && inputs.ghostty.overlays ? default) inputs.ghostty.overlays.default;

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
        programs.ghostty = {
          enable = true;
          enableZshIntegration = true;
          enableBashIntegration = true;
          installBatSyntax = true;
          installVimSyntax = true;
        };

        home.file.".config/ghostty" = {
          source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/ghostty";
          recursive = true;
        };

        home.file.".local/bin/gshader" = {
          text = ''
            #!/usr/bin/env bash
            exec ${dotsPath}/ghostty/shader.sh "$@"
          '';
          executable = true;
        };
      };
  };
}
