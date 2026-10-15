# Nix Developer Tools Aspect
{ den, ... }:
{
  den.aspects.applications.dev.lang.nix = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          devenv
          manix
          nix-prefetch-scripts
          nix-prefetch-github
          nix-tree
        ];
      };
  };
}
