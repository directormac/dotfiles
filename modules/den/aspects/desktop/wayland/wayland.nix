{den, ...}: {
  den.aspects.desktop.wayland = {
    nixos = {pkgs, ...}: {
      environment = {
        systemPackages = with pkgs; [
          quickshell
          wl-clipboard
          xwayland-satellite
          cliphist

          # move to sddm later
          kdePackages.qtmultimedia
        ];

        sessionVariables = {
          WLR_NO_HARDWARE_CURSORS = "1";
          # Force Electron/Chromium apps to use Wayland
          NIXOS_OZONE_WL = "1";
          # Force Firefox/Zen to use Wayland natively
          MOZ_ENABLE_WAYLAND = "1";
        };
      };
    };

    # services.displayManager.sddm.enable = true;
    #
    # services.displayManager = {
    #   enable = true;
    # };
  };

  den.aspects.wayland.includes = [
    den.aspects.desktop.uwsm
    den.aspects.desktop.hyprland
    den.aspects.desktop.niri
  ];
}
