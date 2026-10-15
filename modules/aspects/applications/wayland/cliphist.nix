# Cliphist Wayland Clipboard History Leaf Aspect
{ den, ... }:
{
  den.aspects.applications.wayland.cliphist = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          cliphist
          wl-clip-persist
          wl-clipboard
        ];
      };
  };
}
