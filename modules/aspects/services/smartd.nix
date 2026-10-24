# Service Smartd Disk Health Monitoring Aspect
{
  den.aspects.services.smartd = {

    nixos =
      {
        lib,
        pkgs,
        ...
      }:
      {
        environment.systemPackages = with pkgs; [
          smartmontools
        ];

        services.smartd = {
          enable = lib.mkDefault true;
          autodetect = true;
        };
      };
  };
}
