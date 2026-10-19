# Hyprland Wayland Compositor Leaf Aspect
{
  lib,
  ...
}:
{
  den.aspects.desktop.hyprland = {
    settings = {
      cardDevice = lib.mkOption {
        default = null;
        description = "Primary or multi-GPU device string (e.g. /dev/dri/card2:/dev/dri/card1)";
        type = lib.types.nullOr lib.types.str;
      };

      enableUWSM = lib.mkOption {
        default = true;
        description = "Enable UWSM session wrapper for Hyprland";
        type = lib.types.bool;
      };
    };

    nixos =
      {
        lib,
        pkgs,
        host ? null,
        ...
      }:
      let
        cfg =
          host.settings.desktop.hyprland or host.settings.core.hyprland or {
            cardDevice = null;
            enableUWSM = true;
          };
      in
      {
        environment.sessionVariables = lib.mkIf (cfg.cardDevice != null) {
          AQ_DRM_DEVICES = cfg.cardDevice;
        };

        environment.systemPackages = with pkgs; [
          wl-clipboard
          wlr-randr
          brightnessctl
          playerctl
          xdg-utils
        ];

        programs.hyprland = {
          enable = lib.mkDefault true;
          withUWSM = lib.mkDefault cfg.enableUWSM;
          xwayland.enable = lib.mkDefault true;
        };

        programs.uwsm.enable = lib.mkDefault cfg.enableUWSM;

        virtualisation.vmVariant = {
          environment.sessionVariables = {
            HYPRLAND_IS_VM = "1";
            HYPRLAND_MOD = "ALT";
          };

          services.xserver.desktopManager.xterm.enable = false;
        };
      };

    homeManager =
      {
        config,
        pkgs,
        ...
      }:
      {
        home.packages = with pkgs; [
          hyprlauncher
          hyprland-qt-support
          hyprland-preview-share-picker
        ];

        xdg.configFile."hypr".source = config.lib.dots.link "hypr";
      };

    persistHome.directories = [
      ".local/share/hyprland"
    ];
  };

}
