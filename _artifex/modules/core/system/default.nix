{ core, ... }: {
  core.system.includes = with core; [
    system.firmware
    system.linux-kernel
    system.plymouth
  ];
}
