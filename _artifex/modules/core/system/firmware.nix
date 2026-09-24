{
  core.system.firmware = {
    nixos = {
      hardware.enableAllFirmware = true;
      hardware.enableRedistributableFirmware = true;
      services.fwupd.enable = true;
    };

    cache.directories = [ "/var/cache" ];
    persist.files = [ "/etc/machine-id" ];
  };
}
