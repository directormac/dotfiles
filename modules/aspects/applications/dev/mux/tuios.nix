# TUIOS Terminal UI Operating System Multiplexer Aspect
{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    tuios.url = "github:Gaurav-Gosain/tuios";
  };

  den.aspects.applications.dev.mux.tuios = {
    nixos =
      { pkgs, ... }:
      let
        tuiosPkg =
          if inputs ? tuios then
            inputs.tuios.packages.${pkgs.stdenv.hostPlatform.system}.tuios
              or inputs.tuios.packages.${pkgs.stdenv.hostPlatform.system}.default
          else
            null;
      in
      {
        environment.systemPackages = lib.optional (tuiosPkg != null) tuiosPkg;
      };

    homeManager =
      {
        config,
        pkgs,
        ...
      }:
      let
        tuiosPkg =
          if inputs ? tuios then
            inputs.tuios.packages.${pkgs.stdenv.hostPlatform.system}.tuios
              or inputs.tuios.packages.${pkgs.stdenv.hostPlatform.system}.default
          else
            null;
        tuios-tmux-shim = pkgs.writeShellScriptBin "tuios-tmux-shim" ''
          set -euo pipefail
          if [ -z "''${TUIOS_SESSION:-}" ] && [ -z "''${TMUX:-}" ]; then
            SOCKET="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/tuios/tmux/socket"
            if [ -S "$SOCKET" ]; then
              SHIM_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/tuios/tmux-bin"
              mkdir -p "$SHIM_DIR"
              ln -sf "$(command -v tuios)" "$SHIM_DIR/tmux"
              exec "$SHIM_DIR/tmux" -S "$SOCKET" "$@"
            fi
          fi
          exec tuios tmux-shim "$@"
        '';
      in
      {
        home.file.".config/tuios" = {
          recursive = true;
          source = config.lib.dots.link "tuios";
        };

        home.packages = lib.optionals (tuiosPkg != null) [
          tuiosPkg
          tuios-tmux-shim
        ];
      };

    persistHome.directories = [
      ".local/share/tuios"
      ".local/state/tuios"
    ];
  };
}
