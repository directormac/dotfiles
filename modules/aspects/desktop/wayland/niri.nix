{den, ...}: {
  den.aspects.desktop.niri = {
    includes = [
      # den.aspects.desktop.noctalia
    ];

    nixos = {pkgs, ...}: {
      programs.niri.enable = true;

      environment = {
        systemPackages = with pkgs; [
          ghostty
          kitty
          wl-clipboard
          xwayland-satellite
          quickshell
          cliphist
          swaybg

          # move to sddm later
          kdePackages.qtmultimedia
        ];

        sessionVariables = {
          EDITOR = "nvim";
          WLR_NO_HARDWARE_CURSORS = "1";
          # Force Electron/Chromium apps to use Wayland
          NIXOS_OZONE_WL = "1";
          # Force Firefox/Zen to use Wayland natively
          MOZ_ENABLE_WAYLAND = "1";
        };
      };
    };

    homeManager = {
      pkgs,
      lib,
      config,
      ...
    }: {
      wayland.windowManager.niri = {
        enable = true;
        settings = {
          hotkey-overlay.skip-at-startup = true;
          prefer-no-csd = true;

          binds = {
            "Mod+Return".spawn = ["kitty"];
            "Mod+Q".close-window = {};
          };
        };
        xwaylandSatellitePackage = pkgs.xwayland-satellite;
        extraConfig = ''
          spawn-at-startup "${lib.getExe pkgs.swaybg}" "-c" "#0000ff"
        '';
      };
    };
  };
}
