{ self, inputs, ... }: {
  flake.nixosModules.nocturnal-niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.nocturnal-niri;
    };
  };

  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      packages.nocturnal-niri = inputs.wrappers.wrappers.niri.wrap {
        inherit pkgs;
        # runtimePkgs = [
        #   self'.packages.menu1
        # ];
        settings = {
          spawn-at-startup = [
            (lib.getExe self'.packages.noctalia)
          ];

          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

          input.keyboard.xkb.layout = "us";

          layout = {
            gaps = 3;
            center-focused-column = "never";
            always-center-single-column = [ ];
            focus-ring = {
              width = 1;
            };
            border = {
              off = [ ];
              width = 0;
            };
          };

          outputs."Virtual-1" = {
            # Use your actual VM display name here
            mode = "1920x1080@60.0";
          };

          binds = {
            "Mod+Return".spawn-sh = lib.getExe pkgs.ghostty;

            "Mod+Q".close-window = [ ];
            "Mod+F".maximize-column = [ ];
            "Mod+G".fullscreen-window = [ ];
            "Mod+Shift+F".toggle-window-floating = [ ];
            "Mod+C".center-column = [ ];

            "Mod+H".focus-column-left = [ ];
            "Mod+L".focus-column-right = [ ];
            "Mod+K".focus-window-up = [ ];
            "Mod+J".focus-window-down = [ ];

            "Mod+Left".focus-column-left = [ ];
            "Mod+Right".focus-column-right = [ ];
            "Mod+Up".focus-window-up = [ ];
            "Mod+Down".focus-window-down = [ ];

            "Mod+Shift+H".move-column-left = [ ];
            "Mod+Shift+L".move-column-right = [ ];
            "Mod+Shift+K".move-window-up = [ ];
            "Mod+Shift+J".move-window-down = [ ];

            "Mod+1".focus-workspace = "w0";
            "Mod+2".focus-workspace = "w1";
            "Mod+3".focus-workspace = "w2";
            "Mod+4".focus-workspace = "w3";
            "Mod+5".focus-workspace = "w4";
            "Mod+6".focus-workspace = "w5";
            "Mod+7".focus-workspace = "w6";
            "Mod+8".focus-workspace = "w7";
            "Mod+9".focus-workspace = "w8";
            "Mod+0".focus-workspace = "w9";

            "Mod+Shift+1".move-column-to-workspace = "w0";
            "Mod+Shift+2".move-column-to-workspace = "w1";
            "Mod+Shift+3".move-column-to-workspace = "w2";
            "Mod+Shift+4".move-column-to-workspace = "w3";
            "Mod+Shift+5".move-column-to-workspace = "w4";
            "Mod+Shift+6".move-column-to-workspace = "w5";
            "Mod+Shift+7".move-column-to-workspace = "w6";
            "Mod+Shift+8".move-column-to-workspace = "w7";
            "Mod+Shift+9".move-column-to-workspace = "w8";
            "Mod+Shift+0".move-column-to-workspace = "w9";

            "Mod+Ctrl+H".set-column-width = "-5%";
            "Mod+Ctrl+L".set-column-width = "+5%";
            "Mod+Ctrl+J".set-window-height = "-5%";
            "Mod+Ctrl+K".set-window-height = "+5%";

            "Mod+WheelScrollDown".focus-column-left = [ ];
            "Mod+WheelScrollUp".focus-column-right = [ ];
            "Mod+Ctrl+WheelScrollDown".focus-workspace-down = [ ];
            "Mod+Ctrl+WheelScrollUp".focus-workspace-up = [ ];

            "Mod+Space".spawn-sh = "${lib.getExe pkgs.noctalia} msg panel-toggle launcher";
            "Mod+D".spawn-sh = "${lib.getExe self'.packages.menu1}";
            "Mod+S".spawn-sh = "${lib.getExe pkgs.noctalia} msg panel-toggle control-center";
            "Mod+Comma".spawn-sh = "${lib.getExe pkgs.noctalia} msg settings-toggle";
            "Alt+Tab".spawn-sh = "${lib.getExe pkgs.noctalia} msg window-switcher";

            "XF86AudioRaiseVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
            "XF86AudioLowerVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";

            # "XF86AudioRaiseVolume".spawn-sh = "${lib.getExe pkgs.noctalia}  msg volume-up";
            # "XF86AudioLowerVolume".spawn-sh = "${lib.getExe pkgs.noctalia}  msg volume-down";
            "XF86AudioMute".spawn-sh = "${lib.getExe pkgs.noctalia}  msg volume-mute";
          };
        };
      };
    };
}
