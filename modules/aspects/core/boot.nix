# Core Boot & Kernel Aspect
{ den, ... }:
{
  den.aspects.core.boot = {
    nixos =
      {
        host,
        lib,
        pkgs,
        ...
      }:
      {
        boot = {
          consoleLogLevel = lib.mkDefault 0;

          initrd = {
            kernelModules = [
              "amdgpu"
              "i915"
            ];
            verbose = lib.mkDefault false;
          };

          kernel.sysctl."kernel.perf_event_paranoid" = 0;
          kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

          kernelParams = [
            "quiet"
            "rd.udev.log_level=3"
            "rd.systemd.show_status=auto"
          ];

          loader = {
            efi.canTouchEfiVariables = lib.mkDefault true;

            systemd-boot = {
              configurationLimit = lib.mkDefault 10;
              enable = lib.mkDefault true;
            };

            timeout = lib.mkDefault 3;
          };

          plymouth.enable = lib.mkDefault (host.isWorkstation or true);
        };
      };
  };
}
