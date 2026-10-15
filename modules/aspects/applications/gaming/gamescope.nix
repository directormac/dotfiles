# Gamescope Micro-Compositor Aspect
{ den, ... }:
{
  den.aspects.applications.gaming.gamescope = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.gamescope
        ];

        programs.gamescope = {
          enable = true;
          capSysNice = true;
          package = pkgs.gamescope;
          args = [
            "--rt"
            "--expose-wayland"
          ];
        };
      };
  };
}
