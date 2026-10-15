# Fcitx5 Input Method Framework Leaf Aspect
{ den, ... }:
{
  den.aspects.applications.wayland.fcitx5 = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.fcitx5
        ];
      };
  };
}
