# Nix Developer Tools Aspect
_:
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
