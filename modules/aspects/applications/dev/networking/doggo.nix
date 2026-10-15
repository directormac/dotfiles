# Doggo DNS Client Aspect
{ den, ... }:
{
  den.aspects.applications.dev.networking.doggo = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.doggo
        ];
      };
  };
}
