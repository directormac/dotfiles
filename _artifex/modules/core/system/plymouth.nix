{
  core.system.plymouth = {
    nixos = {
      boot = {
        consoleLogLevel = 3;
        initrd.verbose = false;

        kernelParams = [
          "quiet"
          "splash"
          "intremap=on"
          "boot.shell_on_fail"
          "udev.log_priority=3"
          "rd.systemd.show_status=auto"
        ];

        plymouth.enable = true;
      };
    };

    # persist = {
    #   directories = ["/var/lib/plymouth"];
    # };
  };
}
