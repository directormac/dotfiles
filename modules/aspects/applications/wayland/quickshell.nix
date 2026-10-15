# Quickshell Wayland Desktop Shell Toolkit Leaf Aspect
{ den, ... }:
{
  den.aspects.applications.wayland.quickshell = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.quickshell
        ];
      };
  };
}
