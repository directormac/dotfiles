{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
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
      packages.myNiri = inputs.wrappers.wrappers.niri.wrap {
        inherit pkgs;
        settings = {
          spawn-at-startup = [
            (lib.getExe self'.packages.noctalia)
          ];

          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

          input.keyboard.xkb.layout = "us";

          layout.gaps = 5;

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
