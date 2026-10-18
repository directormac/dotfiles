# Service Tailscale VPN Aspect
{
  den.aspects.services.tailscale = {
    nixos =
      { lib, pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.tailscale ];
        services.tailscale.enable = lib.mkDefault true;
      };

    persist.directories = [
      "/var/lib/tailscale"
    ];
  };
}
