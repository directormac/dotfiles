# Btop Resource Monitor Aspect
{
  den.aspects.applications.dev.shell.btop = {
    homeManager =
      { pkgs, ... }:
      {
        stylix.targets.btop.enable = true;

        programs.btop = {
          enable = true;
          package = pkgs.btop.override { rocmSupport = true; };
          settings = {
            theme_background = false;
            truecolor = true;
            force_tty = false;
            disable_presets = "Off";
            rounded_corners = false;
            vim_keys = true;
            shown_boxes = "cpu mem net proc";
            presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";
            graph_symbol = "braille";
          };
        };
      };
  };
}
