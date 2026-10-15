# Enables `nix run .#vm` and `nix run .#vm-<host-name>`
# Modular VM flavors: core.vm, core.vm.gui (XFCE), core.vm.tui, and sandbox test host
{
  lib,
  core,
  den,
  inputs,
  ...
}:
let
  installer = variant: {
    nixos =
      { modulesPath, ... }:
      {
        imports = [
          "${modulesPath}/installer/cd-dvd/installation-cd-${variant}.nix"
        ];
      };
  };
in
{
  core.virtualisation = {
    nixos = {
      virtualisation.vmVariant = {
        virtualisation.qemu.enableSharedMemory = true;
      };
    };
  };

  core.vm = {
    includes = [
      core.virtualisation
    ];

    nixos =
      { lib, ... }:
      {
        virtualisation.vmVariant = {
          fileSystems."/cache" = lib.mkVMOverride {
            options = [
              "defaults"
              "mode=755"
            ];

            device = "none";
            fsType = "tmpfs";
            neededForBoot = true;
          };

          # In a test VM, provide tmpfs backings for /persist and /cache so impermanence
          # bind mounts function cleanly without requiring physical host disks.
          fileSystems."/persist" = lib.mkVMOverride {
            options = [
              "defaults"
              "mode=755"
            ];

            device = "none";
            fsType = "tmpfs";
            neededForBoot = true;
          };

          # Enable SSH inside test VMs for remote access testing
          services.openssh = {
            settings = {
              PasswordAuthentication = true;
              PermitRootLogin = "yes";
            };

            enable = true;
          };

          # Ensure user artifex has password in VM for SSH testing
          users.users.artifex.password = "12345";

          virtualisation = {
            cores = lib.mkDefault 4;

            forwardPorts = [
              {
                from = "host";
                guest.port = 22;
                host.port = 2222;
              }
            ];

            graphics = lib.mkDefault true;
            memorySize = lib.mkDefault 4096;
          };

          # Mount live dotfiles directory and development worktrees from the host into the VM
          # Preserves exact paths for git worktrees while providing ~/.dotfiles fallback
          virtualisation.sharedDirectories = {
            code = {
              source = "\"\${CODE_DIR:-$HOME/Code}\"";
              target = "/home/artifex/Code";
            };

            dotfiles = {
              source = "\"\${DOTFILES_DIR:-$PWD}\"";
              target = "/home/artifex/.dotfiles";
            };
          };
        };
      };

    gui.includes = [
      core.vm
      core.vm-bootable.gui
      core.xfce-desktop
    ];

    tui.includes = [
      core.vm
      core.vm-bootable.tui
    ];
  };

  core.vm-bootable = {
    gui = installer "graphical-base";
    tui = installer "minimal";
  };

  core.xfce-desktop.nixos =
    { lib, ... }:
    {
      services.displayManager = {
        defaultSession = lib.mkDefault "xfce";
        enable = true;
      };

      services.xserver = {
        desktopManager = {
          xfce.enable = true;
          xterm.enable = false;
        };

        enable = true;
      };
    };

  den.aspects.nixos.includes = [
    core.vm
    (den.batteries.vm-autologin "artifex")
  ];

  # Host sandbox: lightweight testbed host
  den.aspects.sandbox = {
    includes = [
      core.vm.gui
      (den.batteries.vm-autologin "artifex")
    ];

    nixos = {
      networking.hostName = "sandbox";
      system.stateVersion = "26.05";
    };
  };

  # Host super and nixos get core.vm and vm-autologin
  den.aspects.super.includes = [
    core.vm
    (den.batteries.vm-autologin "artifex")
  ];

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
