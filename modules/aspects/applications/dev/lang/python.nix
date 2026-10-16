# Nix Developer Tools Aspect
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
