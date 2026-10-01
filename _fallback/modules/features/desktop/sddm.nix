{
  inputs,
  lib,
  ...
}:
let
  wallpaper = ../../../../config/wallpapers/anime_girl_holding_tea_1080p.mp4;
  profileIcon = ../../../../config/avatar.jpg;

in
{
  flake.nixosModules.sddm = { config, ... }: {
    # config.preferences.user.name
    imports = [ inputs.silentSDDM.nixosModules.default ];
    # programs.silentSDDM = {
    #   enable = true;
    #   theme = "rei";
    #   # settings = { ... }; see example in module
    # };
    #
    programs.silentSDDM = {
      enable = true;
      theme = "rei";
      backgrounds = {
        output = wallpaper;
      };
      profileIcons.${config.preferences.user.name} = profileIcon;
      settings = {
        "General" = {
          "animated-background-placeholder" = "";
          "background-fill-mode" = "fill";
        };
        "LoginScreen" = {
          background = "anime_girl_holding_tea_1080p.mp4";
          use-background-color = false;
        };
        "LockScreen" = {
          display = false;
          background = "anime_girl_holding_tea_1080p.mp4";
          use-background-color = false;
        };
      };
    };

    services.displayManager = {
      sddm = {
        enable = true;
      };
      defaultSession = config.preferences.defaultSession;
    };

  };
}
