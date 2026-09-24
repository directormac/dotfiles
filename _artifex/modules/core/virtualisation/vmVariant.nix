{
  core.virtualisation = {
    nixos = {
      virtualisation.vmVariant = {
        virtualisation.qemu.enableSharedMemory = true;
      };
    };
  };
}
