{artifex, ...}: {
  eg.vm = {
    gui.includes = [
      artifex.vm
      artifex.vm-bootable.gui
      artifex.xfce-desktop
    ];

    tui.includes = [
      artifex.vm
      artifex.vm-bootable.tui
    ];
  };
}
