{ inputs, self, ... }:
{
  flake.homeModules.noctalia =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      flakePath = "${config.home.homeDirectory}/.dotfiles";
    in
    {

      programs.noctalia = {
        enable = true;

        settings = {

          shell = {
            screenshot = {
              annotate = true;
            };
          };

          theme = {
            bultin = "Catppuccin";
            custom_palette = "stylix";
            mode = "dark";
            source = "custom";
          };

          bar = {
            background_opacity = 0;
            font_family = "NotoMono NF";
            margin_ends = 0;
            radius_bottom_left = 0;
            radius_bottom_right = 0;
          };

          weather = {
            enabled = true;
            unit = "metric";
          };

          sysmon = {
            enabled = true;
          };

          notification = {
            enabled = true;
            position = "top-right";
          };

          wallpaper = {
            directory = "${config.home.homeDirectory}/.config/wallpapers";
            automation.enable = true;
          };

          widget = {
            workspaces = {
              hide_when_empt = true;
              scale = 1.2;
              style = "focus_hint";
            };

          };

        };
      };
    };

  flake.nixosModules.noctalia =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        inputs.noctalia.nixosModules.default
      ];

      home-manager.users.${config.preferences.user.name} = {
        imports = [
          self.homeModules.noctalia
        ];
      };

      programs.noctalia = {
        enable = true;
        recommendedServices.enable = true;
      };
    };
}
