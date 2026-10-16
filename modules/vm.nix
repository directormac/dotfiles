# Flake-parts module: VM runner apps and packages
# Enables `nix run .#vm` and `nix run .#vm-<host-name>`
{
  lib,
  inputs,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    let
      defaultVm =
        let
          app = pkgs.writeShellApplication {
            name = "vm";

            text = ''
              export CODE_DIR="''${CODE_DIR:-$HOME/Code}"
              if [ ! -d "$CODE_DIR" ]; then
                mkdir -p "$CODE_DIR"
              fi
              export DOTFILES_DIR="''${DOTFILES_DIR:-$PWD}"
              if [ ! -d "$DOTFILES_DIR/config" ] && [ -d "$HOME/.dotfiles/config" ]; then
                export DOTFILES_DIR="$HOME/.dotfiles"
              fi
              ${host.system.build.vm}/bin/run-${host.networking.hostName}-vm "$@"
            '';
          };
          host = inputs.self.nixosConfigurations.super.config;
        in
        {
          program = "${app}/bin/vm";
          type = "app";
          meta.description = "Run super in a QEMU VM";
        };
      hosts = builtins.attrNames inputs.self.nixosConfigurations;
      vms = map (
        hostName:
        let
          app = pkgs.writeShellApplication {
            name = vmName;

            text = ''
              export CODE_DIR="''${CODE_DIR:-$HOME/Code}"
              if [ ! -d "$CODE_DIR" ]; then
                mkdir -p "$CODE_DIR"
              fi
              export DOTFILES_DIR="''${DOTFILES_DIR:-$PWD}"
              if [ ! -d "$DOTFILES_DIR/config" ] && [ -d "$HOME/.dotfiles/config" ]; then
                export DOTFILES_DIR="$HOME/.dotfiles"
              fi
              ${host.system.build.vm}/bin/run-${hostName}-vm "$@"
            '';
          };
          host = inputs.self.nixosConfigurations.${hostName}.config;
          vmName = "vm-${hostName}";
        in
        {
          name = vmName;

          value = {
            program = "${app}/bin/${vmName}";
            type = "app";
            meta.description = "Run ${hostName} in a QEMU VM for testing before applying changes.";
          };
        }
      ) hosts;
      vmsAttr = builtins.listToAttrs vms;
    in
    {
      apps =
        vmsAttr
        // {
          vm = defaultVm;
        }
        // (lib.optionalAttrs (vmsAttr ? vm-sandbox) {
          sandbox = vmsAttr.vm-sandbox;
        });

      packages.vm = pkgs.writeShellApplication {
        name = "vm";

        text = ''
          export DOTFILES_DIR="''${DOTFILES_DIR:-$PWD}"
          if [ ! -d "$DOTFILES_DIR/config" ] && [ -d "$HOME/.dotfiles/config" ]; then
            export DOTFILES_DIR="$HOME/.dotfiles"
          fi
          ${inputs.self.nixosConfigurations.super.config.system.build.vm}/bin/run-super-vm "$@"
        '';
      };
    };
}
