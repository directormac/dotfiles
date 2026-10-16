# Doggo DNS Client Aspect
_:
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
