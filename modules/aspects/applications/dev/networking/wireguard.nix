# WireGuard Tools Aspect
{ den, ... }:
{
  den.aspects.applications.dev.networking.wireguard = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.wireguard-tools
        ];
      };
  };
}
