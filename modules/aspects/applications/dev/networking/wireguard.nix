# WireGuard Tools Aspect
_:
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
