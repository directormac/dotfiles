# Desktop XServer Base & QtWayland Leaf Aspect
{ den, ... }:
{
  den.aspects.desktop.xserver = {
    nixos =
      { lib, pkgs, ... }:
      {
        services.xserver = {
          enable = lib.mkDefault true;
          exportConfiguration = true;
          excludePackages = [ pkgs.xterm ];
          xkb = {
            layout = "us";
            variant = "";
          };
        };

        environment.systemPackages = with pkgs; [
          qt5.qtwayland
          qt6.qtwayland
          wev
        ];
      };
  };
}
