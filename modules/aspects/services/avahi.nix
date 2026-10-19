# Service Avahi mDNS Aspect
{
  den.aspects.services.avahi = {
    nixos =
      { lib, ... }:
      {
        services.avahi = {
          enable = lib.mkDefault true;
          browseDomains = [ ];
          nssmdns4 = lib.mkDefault true;
        };
      };
  };
}
