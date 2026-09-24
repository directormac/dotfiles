{ core, ... }:
let
  installer = variant: {
    nixos = { modulesPath, ... }: {
      imports = [
        "${modulesPath}/installer/cd-dvd/installation-cd-${variant}.nix"
        # TODO: This is TTY only?
        # "${modulesPath}/virtualisation/qemu-vm.nix"
      ];
    };
  };
in
{
  core.vm = {
    nixos = {
      virtualisation.vmVariantWithBootLoader = { };
    };

    gui.includes = [
      core.vm
      core.vm-bootable.gui
    ];

    tui.includes = [
      core.vm
      core.vm-bootable.tui
    ];
  };

  # make USB/VM installers.
  core.vm-bootable.provides = {
    gui = installer "graphical-base";
    tui = installer "minimal";
  };

  core.xfce-desktop.nixos = { lib, ... }: {
    services.displayManager = {
      defaultSession = lib.mkDefault "xfce";
      enable = true;
    };

    # https://gist.github.com/nat-418/1101881371c9a7b419ba5f944a7118b0
    services.xserver = {
      desktopManager = {
        xfce.enable = true;
        xterm.enable = false;
      };

      enable = true;
    };
  };
}
