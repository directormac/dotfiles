{
  runner,
  lib,
  ...
}: {
  runner.vm = {
    gui.includes = [
      runner.vm
      runner.vm-bootable.gui
    ];

    tui.includes = [
      runner.vm
      runner.vm-bootable.tui
    ];

    # nixos = {
    #   virtualisation.vmVariant = {
    #     virtualisation.qemu.enableSharedMemory = true;
    #   };
    # };
  };
}
