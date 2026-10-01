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

      # home.file.".config/noctalia" = {
      #   source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/noctalia";
      #   recursive = true;
      # };

      programs.noctalia = {
        enable = true;

        settings = {

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
    };
}
