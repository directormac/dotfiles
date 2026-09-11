# Bootloader configuration shared across all hosts.
# Uses systemd-boot with EFI, quiet/splash kernel params,
# and zero-second timeout for fast boots.
{
  den.default.nixos.boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      timeout = 0;
      systemd-boot.consoleMode = "max";
    };
    consoleLogLevel = 4;
    kernelParams = [
      "quiet"
      "splash"
    ];
  };
}
