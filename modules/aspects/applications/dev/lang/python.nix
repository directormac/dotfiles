# Nix Developer Tools Aspect
_:
{
  den.aspects.applications.dev.lang.python = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          python3
          uv
        ];
      };
  };
}
