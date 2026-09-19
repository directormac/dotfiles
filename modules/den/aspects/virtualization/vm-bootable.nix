let
  installer = variant: {
    nixos = {modulesPath, ...}: {
      imports = [
        "${modulesPath}/installer/cd-dvd/installation-cd-${variant}.nix"
        # TODO: This is TTY only?
        # "${modulesPath}/virtualisation/qemu-vm.nix"
      ];
    };
  };
in {
  # make USB/VM installers.
  runner.vm-bootable.provides = {
    tui = installer "minimal";
    gui = installer "graphical-base";
  };
}
