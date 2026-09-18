{self, ...}: {
  flake.wrappers.which-key-cli = {...}: {
    settings = {
      font = "Fira Mono Nerd Font 16";
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

  flake.wrappers.which-key-wrapper = {
    wlib,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      wlib.wrapperModules.wlr-which-key
      self.wrapperModules.which-key-cli
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
        key = "k";
        desc = "Kitty";
        cmd = "kitty";
      }
      {
        key = "t";
        desc = "Ghostty";
        cmd = "ghostty";
      }
      {
        key = "w";
        desc = "Toggle Show Keys";
        cmd = "${lib.getExe (
          pkgs.writeShellScriptBin "toggle-wshowkeys" ''
            if pgrep -x wshowkeys > /dev/null; then
              pkill -x wshowkeys
            else
              wshowkeys -a bottom -m 10 -F "Fira Mono Nerd Font 24" -s "#cba6f7ff" -f "#cdd6f4ff" -b "#1e1e2eff" -l 600 -t 2000 -U -M -S &
            fi
          ''
        )}";
      }
      {
        key = "s";
        desc = "Pavucontrol";
        cmd = "pavucontrol";
      }
    ];
  };

  flake.wrappers.which-keyDynamic = {...}: {
    imports = [self.wrapperModules.which-key-wrapper];
    dynamicMode = true;
  };

  perSystem = {
    pkgs,
    self',
    lib,
    ...
  }: {
    packages.which-key = pkgs.writeShellScriptBin "which-key" ''
      exec ${lib.getExe self'.packages.which-key-wrapper} "$@"
    '';

    wrappers.control_type = "exclude"; # | "build" (default: "exclude")
    wrappers.packages = {
      # dynamic = true;
      which-key-cli = true;
    };
  };
}
