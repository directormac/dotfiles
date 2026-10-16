# Thunar File Manager & Plugins Leaf Aspect
{
  den.aspects.desktop.thunar = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          thunar
          thunar-archive-plugin
          thunar-volman
          thunar-media-tags-plugin
          thunar-vcs-plugin
          thunar-shares-plugin
        ];

        programs.xfconf.enable = true;
      };
  };
}
