# Fuzzel Wayland Application Launcher Leaf Aspect
_:
{
  den.aspects.applications.wayland.fuzzel = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.fuzzel
        ];
      };

    homeManager =
      { lib, ... }:
      {
        stylix.targets.fuzzel.enable = lib.mkDefault true;
      };
  };
}
