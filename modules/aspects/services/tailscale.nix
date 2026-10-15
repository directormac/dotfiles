# Service Tailscale VPN Aspect
{ den, ... }:
{
  den.aspects.services.tailscale = {
    nixos =
      { lib, pkgs, ... }:
      {
        services.tailscale.enable = lib.mkDefault true;
        environment.systemPackages = [ pkgs.tailscale ];
      };
  };
}
