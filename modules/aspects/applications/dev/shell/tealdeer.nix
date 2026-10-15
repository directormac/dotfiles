# Tealdeer tldr Client Aspect
{
  den.aspects.applications.dev.shell.tealdeer = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.tealdeer
        ];
      };
  };
}
