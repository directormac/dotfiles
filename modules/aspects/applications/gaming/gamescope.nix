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
          enable = true;

          args = [
            "--rt"
            "--expose-wayland"
            "-g"
          ];

          capSysNice = true;
        };
      };
  };
}
