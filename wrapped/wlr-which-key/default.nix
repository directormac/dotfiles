{ self, ... }: {
  flake.wrappers.which-key = { ... }: {
    settings = {
      font = "Fira Mono Nerd Font 14";
      background = self.theme.base00;
      color = self.theme.base06;
      border = self.theme.base0F;
      separator = " ➜ ";
      border_width = 1;
      # corner_r = 15;
      padding = 15;
      rows_per_column = 5;
      column_padding = 25;

      anchor = "center";
      margin_right = 0;
      margin_bottom = 5;
      margin_left = 5;
      margin_top = 0;
    };
  };

  flake.wrappers.menu1 =
    {
      wlib,
      pkgs,
      lib,
      config,
      ...
    }:
    {
      imports = [
        wlib.wrapperModules.wlr-which-key
        self.wrapperModules.which-key
        self.wrapperModules.dynamic
      ];

      config.settings.menu = [
        {
          key = "f";
          desc = "Firefox";
          cmd = "firefox";
        }
        {
          key = "z";
          desc = "Zen Browser";
          cmd = "zen-beta";
        }
        {
          key = "z";
          desc = "Zen Browser";
          cmd = "zen-beta";
        }
        {
          key = "k";
          desc = "Kitty";
          cmd = "kitty";
        }
        {
          key = "t";
          desc = "Ghostty";
          cmd = "ghostty";
        }
        # {
        #   key = "d";
        #   desc = "Discord";
        #   cmd = "vesktop";
        # }
        # {
        #   key = "D";
        #   desc = "Discord (alt)";
        #   cmd = "vesktop-alt";
        # }
        # {
        #   key = "m";
        #   desc = "Youtube Music";
        #   cmd = "pear-desktop";
        # }
        {
          key = "s";
          desc = "Pavucontrol";
          # cmd = "${lib.getExe pkgs.pavucontrol}";
          cmd = "pavucontrol";
        }
      ];
    };

  flake.wrappers.menu1Dynamic = { ... }: {
    imports = [ self.wrapperModules.menu1 ];
    dynamicMode = true;
  };
}
