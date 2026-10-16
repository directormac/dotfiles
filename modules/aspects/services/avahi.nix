# Service Avahi mDNS Aspect
{
  den.aspects.services.avahi = {
    nixos =
      { lib, ... }:
      {
        services.avahi = {
          browseDomains = [ ];
          enable = lib.mkDefault true;
          nssmdns4 = lib.mkDefault true;
        };
      };
  };
}
