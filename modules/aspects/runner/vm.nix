{
  runner,
  lib,
  ...
}: {
  runner.vm = {
    gui.includes = [
      runner.vm
      runner.vm-bootable.gui

      # runner.hyprland-wm
      # runner.xfce-desktop
      # runner.kde-desktop
    ];

    tui.includes = [
      runner.vm
      runner.vm-bootable.tui
    ];

    nixos = {
      virtualisation.vmVariant = {
        virtualisation.qemu.enableSharedMemory = true;
      };
    };
  };
}
