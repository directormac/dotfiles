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

          # Declarative Plugins: Add plugin IDs here.
          plugins = {
            enabled = [
              # "author/pluginName"
              "noctalia/timer"
              "noctalia/mpvpaper"
              "noctalia/screen_recorder"
              "noctalia/kaomoji"
              "gambled23/mangowm-keymode"
              "ezequiel/mango_layouts"
              "kenn/keybind-cheatsheet"
              "blackbartblues/keymap"
              "mellotanica/launcher-pass"
              "liamwh/emoji-picker"
              "nightwatch75/todo"
              "knyrps/nix-search"

              # "notfinaldev/web-search"
              # "arrifat346afs/systempulse"
              # "gustav0ar/drive-health"
              # "nomadcxx/gamer-mode"
              # "nilsonlinux/link-ip-monitor"
              # "notonux/media-island"
              # "tranzem/media-lyrics"
              # "icefish/phone-connect"
              # "icefish/phone-operate"
              # "ahmedhossamdev/reading-list"
              # "rylos/tailnet"
              # requires nix-search-tv
            ];
          };

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

          dock = {
            shadow = false;
          };

          bar = {
            background_opacity = 0;
            font_family = "NotoMono NF";
            margin_ends = 0;
            radius_bottom_left = 0;
            radius_bottom_right = 0;
            shadow = false;
            contact_shadow = false;
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

      environment.systemPackages = with pkgs; [ gpu-screen-recorder ];

    };
}
