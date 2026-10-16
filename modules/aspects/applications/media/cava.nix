# Cava Audio Visualizer Leaf Aspect
{
  den.aspects.applications.media.cava = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.cava
        ];
      };

    homeManager =
      { lib, ... }:
      {
        stylix.targets.cava.enable = lib.mkDefault true;
      };
  };
}
