# Service Avahi mDNS Aspect
{
  den.aspects.services.avahi = {
    nixos =
      { lib, ... }:
      {
        services.avahi = {
          enable = lib.mkDefault true;
          settings.server.browse-domains = [ ];
          nssmdns4 = lib.mkDefault true;
        };
      };
  };
}
