# SOPS, Rage & SecretSpec Aspect
{ den, ... }:
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
