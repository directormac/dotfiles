# Display Manager & Greeter Leaf Aspect (SilentSDDM Catppuccin)
{
  core,
  den,
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs = {
    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  den.aspects.desktop.greeter = {
    settings = {
      defaultSession = lib.mkOption {
        type = lib.types.str;
        default = "hyprland-uwsm";
        description = "Default Wayland/X11 session for display manager";
      };

      theme = lib.mkOption {
        type = lib.types.str;
        default = "catppuccin-mocha";
        description = "SilentSDDM theme";
      };

      wallpaper = lib.mkOption {
        type = lib.types.str;
        default = "anime_girl_holding_tea_1080p.mp4";
        description = "Background image or video file name in config/wallpapers/";
      };
    };

    nixos =
      {
        host ? null,
        config,
        lib,
        ...
      }:
      let
        cfg = host.settings.desktop.greeter or host.settings.core.greeter or {
          defaultSession = "hyprland-uwsm";
          theme = "catppuccin-mocha";
          wallpaper = "anime_girl_holding_tea_1080p.mp4";
        };
        wallpaperPath = ../../../config/wallpapers + "/${cfg.wallpaper}";
        avatarPath = ../../../config/avatar.jpg;
      in
      {
        imports = lib.optionals (inputs ? silentSDDM) [
          inputs.silentSDDM.nixosModules.default
        ];

        programs.silentSDDM = lib.mkIf (inputs ? silentSDDM) {
          enable = true;
          theme = cfg.theme;
          backgrounds = {
            output = wallpaperPath;
          };
          profileIcons = lib.optionalAttrs (config.users.users ? artifex) {
            artifex = avatarPath;
          };
          settings = {
            "General" = {
              "animated-background-placeholder" = "";
              "background-fill-mode" = "fill";
            };
            "LoginScreen" = {
              background = cfg.wallpaper;
              use-background-color = false;
            };
            "LockScreen" = {
              display = false;
              background = cfg.wallpaper;
              use-background-color = false;
            };
          };
        };

        services.displayManager = {
          defaultSession = lib.mkOverride 900 cfg.defaultSession;
          sddm = {
            enable = lib.mkDefault true;
            wayland.enable = lib.mkDefault true;
            autoNumlock = true;
          };
        };
      };
  };

}
