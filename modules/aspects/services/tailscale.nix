# Service Tailscale VPN Aspect
_:
{
  den.aspects.services.tailscale = {
    nixos =
      { lib, pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.tailscale ];
        services.tailscale.enable = lib.mkDefault true;
      };
  };
}
