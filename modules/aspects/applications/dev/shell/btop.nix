# Btop Resource Monitor Aspect
{
  den.aspects.applications.dev.shell.btop = {
    homeManager =
      { pkgs, ... }:
      {
        programs.btop = {
          enable = true;

          settings = {
            disable_presets = "Off";
            force_tty = false;
            graph_symbol = "braille";
            presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";
            rounded_corners = false;
            shown_boxes = "cpu mem net proc";
            theme_background = false;
            truecolor = true;
            vim_keys = true;
          };

          package = pkgs.btop.override { rocmSupport = true; };
        };

        stylix.targets.btop.enable = true;
      };
  };
}
