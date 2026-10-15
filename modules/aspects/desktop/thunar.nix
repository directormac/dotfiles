# Thunar File Manager & Plugins Leaf Aspect
{ den, ... }:
{
  den.aspects.desktop.thunar = {
    nixos =
      { pkgs, ... }:
      {
        programs.xfconf.enable = true;

        environment.systemPackages = with pkgs; [
          thunar
          thunar-archive-plugin
          thunar-volman
          thunar-media-tags-plugin
          thunar-vcs-plugin
          thunar-shares-plugin
        ];
      };
  };
}
