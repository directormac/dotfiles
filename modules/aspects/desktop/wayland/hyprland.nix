{den, ...}: {
  den.aspects.desktop.hyprland = {
    includes = [
      den.aspects.desktop.dms
    ];

    nixos = {
      lib,
      pkgs,
      ...
    }: {
      # Enable UWSM globally or via the compositor option
      programs.uwsm.enable = true;

      programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };

      environment = {
        systemPackages = with pkgs; [
          kitty
          wl-clipboard
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
      # home.file = {
      #   ".config/hypr" = {
      #     recursive = true;
      #     source = ../../../config/hypr;
      #   };
      # };
    };
  };
}
