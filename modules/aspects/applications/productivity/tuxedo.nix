# Tuxedo CLI Todo / Task Management Aspect
{
  den.aspects.applications.productivity.tuxedo = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.tuxedo
        ];
      };

    homeManager =
      { config, ... }:
      {
        home.file.".config/tuxedo".source = config.lib.dots.link "tuxedo";
      };
  };
}
