# WireGuard Tools Aspect
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
