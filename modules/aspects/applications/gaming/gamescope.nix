# Gamescope Micro-Compositor Aspect
{
  den.aspects.applications.gaming.gamescope = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.gamescope
        ];

        programs.gamescope = {
          args = [
            "--rt"
            "--expose-wayland"
          ];

          capSysNice = true;
          enable = true;
          package = pkgs.gamescope;
        };
      };
  };
}
