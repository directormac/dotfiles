# Virtualization VM-Variant Aspect: QEMU test VM environment configuration
{
  den,
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
  den.aspects.virtualization.vm-bootable = {
    gui = installer "graphical-base";
    tui = installer "minimal";
  };

  den.aspects.virtualization.vm-variant = {
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
            enable = true;

            settings = {
              PasswordAuthentication = true;
              PermitRootLogin = "yes";
            };
          };

          # Ensure user artifex has initialPassword in VM for SSH testing without conflicting with users.users.artifex.initialPassword
          users.users.artifex.initialPassword = lib.mkVMOverride "12345";

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

          virtualisation.qemu.enableSharedMemory = true;

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

    gui.includes = with den.aspects; [
      virtualization.vm-variant
      virtualization.vm-bootable.gui
      virtualization.xfce-desktop
    ];

    tui.includes = with den.aspects; [
      virtualization.vm-variant
      virtualization.vm-bootable.tui
    ];
  };

  den.aspects.virtualization.xfce-desktop.nixos =
    { lib, ... }:
    {
      services.displayManager = {
        enable = true;
        defaultSession = lib.mkDefault "xfce";
      };

      services.xserver = {
        enable = true;

        desktopManager = {
          xfce.enable = true;
          xterm.enable = false;
        };
      };
    };
}
