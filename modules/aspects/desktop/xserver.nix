# Desktop XServer Base & QtWayland Leaf Aspect
{
  den.aspects.desktop.xserver = {
    nixos =
      { lib, pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          qt5.qtwayland
          qt6.qtwayland
          wev
        ];

        services.xserver = {
          enable = lib.mkDefault true;
          excludePackages = [ pkgs.xterm ];
          exportConfiguration = true;

          xkb = {
            layout = "us";
            variant = "";
          };
        };
      };
  };
}
