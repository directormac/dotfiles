# Hyprland Wayland Compositor Leaf Aspect
{
  core,
  den,
  lib,
  ...
}:
{
  den.aspects.desktop.hyprland = {
    settings = {
      enableUWSM = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable UWSM session wrapper for Hyprland";
      };

      cardDevice = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Primary or multi-GPU device string (e.g. /dev/dri/card2:/dev/dri/card1)";
      };
    };

    nixos =
      {
        host ? null,
        pkgs,
        lib,
        ...
      }:
      let
        cfg = host.settings.desktop.hyprland or host.settings.core.hyprland or {
          enableUWSM = true;
          cardDevice = null;
        };
      in
      {
        programs.uwsm.enable = lib.mkDefault cfg.enableUWSM;
        programs.hyprland = {
          enable = lib.mkDefault true;
          withUWSM = lib.mkDefault cfg.enableUWSM;
          xwayland.enable = lib.mkDefault true;
        };

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
        user,
        ...
      }:
      let
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
      in
      {
        home.packages = with pkgs; [
          hyprlauncher
          hyprland-qt-support
          hyprland-preview-share-picker
        ];

        xdg.configFile."hypr".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/hypr";
      };

    persistHome.directories = [
      ".local/share/hyprland"
    ];
  };

}
