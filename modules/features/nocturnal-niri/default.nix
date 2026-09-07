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
            "Mod+Space".spawn-sh = "${lib.getExe pkgs.noctalia} msg panel-toggle launcher";
            "Mod+S".spawn-sh = "${lib.getExe pkgs.noctalia} msg panel-toggle control-center";
            "Mod+Comma".spawn-sh = "${lib.getExe pkgs.noctalia} msg settings-toggle";
            "Alt+Tab".spawn-sh = "${lib.getExe pkgs.noctalia} msg window-switcher";
            "XF86AudioRaiseVolume".spawn-sh = "${lib.getExe pkgs.noctalia}  msg volume-up";
            "XF86AudioLowerVolume".spawn-sh = "${lib.getExe pkgs.noctalia}  msg volume-down";
            "XF86AudioMute".spawn-sh = "${lib.getExe pkgs.noctalia}  msg volume-mute";
          };
        };
      };
    };
}
