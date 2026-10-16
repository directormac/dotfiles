# Display Manager & Greeter Leaf Aspect (SilentSDDM Catppuccin)
{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    silentSDDM = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:uiriansan/SilentSDDM";
    };
  };

  den.aspects.desktop.greeter = {
    settings = {
      defaultSession = lib.mkOption {
        default = "hyprland-uwsm";
        description = "Default Wayland/X11 session for display manager";
        type = lib.types.str;
      };

      theme = lib.mkOption {
        default = "catppuccin-mocha";
        description = "SilentSDDM theme";
        type = lib.types.str;
      };

      wallpaper = lib.mkOption {
        default = "anime_girl_holding_tea_1080p.mp4";
        description = "Background image or video file name in config/wallpapers/";
        type = lib.types.str;
      };
    };

    nixos =
      {
        config,
        lib,
        host ? null,
        ...
      }:
      let
        avatarPath = ../../../config/avatar.jpg;
        cfg =
          host.settings.desktop.greeter or host.settings.core.greeter or {
            defaultSession = "hyprland-uwsm";
            theme = "catppuccin-mocha";
            wallpaper = "anime_girl_holding_tea_1080p.mp4";
          };
        wallpaperPath = ../../../config/wallpapers + "/${cfg.wallpaper}";
      in
      {
        imports = lib.optionals (inputs ? silentSDDM) [
          inputs.silentSDDM.nixosModules.default
        ];

        programs.silentSDDM = lib.mkIf (inputs ? silentSDDM) {
          inherit (cfg) theme;

          settings = {
            "General" = {
              "animated-background-placeholder" = "";
              "background-fill-mode" = "fill";
            };

            "LockScreen" = {
              background = cfg.wallpaper;
              display = false;
              use-background-color = false;
            };

            "LoginScreen" = {
              background = cfg.wallpaper;
              use-background-color = false;
            };
          };

          backgrounds = {
            output = wallpaperPath;
          };

          enable = true;

          profileIcons = lib.optionalAttrs (config.users.users ? artifex) {
            artifex = avatarPath;
          };
        };

        services.displayManager = {
          defaultSession = lib.mkOverride 900 cfg.defaultSession;

          sddm = {
            autoNumlock = true;
            enable = lib.mkDefault true;
            wayland.enable = lib.mkDefault true;
          };
        };
      };
  };

}
