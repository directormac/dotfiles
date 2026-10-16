# SOPS, Rage & SecretSpec Aspect
_:
{
  den.aspects.applications.dev.security.sops = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          rage
          sops
          secretspec
        ];
      };
  };
}
