# Service Avahi mDNS Aspect
{ den, ... }:
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
