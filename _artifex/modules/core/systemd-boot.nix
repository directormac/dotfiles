{
  core.systemd-boot = {
    nixos = {
      boot = {
        kernelParams = [
          "quiet"
          "splash"
        ];

        loader = {
          efi.canTouchEfiVariables = true;

          systemd-boot = {
            configurationLimit = 5;
            consoleMode = "max";
            enable = true;
          };

          # timeout = 0;
        };
      };
    };
  };
}
