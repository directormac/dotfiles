# Service Samba WSDD Network Discovery Aspect
_:
{
  den.aspects.services.samba = {
    nixos =
      { lib, ... }:
      {
        services.samba-wsdd = {
          enable = lib.mkDefault true;
          openFirewall = true;
        };
      };
  };
}
