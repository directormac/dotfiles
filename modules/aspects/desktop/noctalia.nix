# Noctalia Desktop Shell Leaf Aspect
{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    noctalia = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:noctalia-dev/noctalia";
    };
  };

  den.aspects.desktop.noctalia = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ gpu-screen-recorder ];

        imports = lib.optionals (inputs ? noctalia) [
          inputs.noctalia.nixosModules.default
        ];

        programs.noctalia = lib.mkIf (inputs ? noctalia) {
          enable = true;
          recommendedServices.enable = true;
        };
      };

    homeManager =
      { config, ... }:
      {
        programs.noctalia = lib.mkIf (inputs ? noctalia) {
          settings = {
            bar = {
              background_opacity = 0;
              contact_shadow = false;
              font_family = "NotoMono NF";
              margin_ends = 0;
              radius_bottom_left = 0;
              radius_bottom_right = 0;
              shadow = false;
            };

            dock = {
              shadow = false;
            };

            notification = {
              enabled = true;
              position = "top-right";
            };

            plugins = {
              enabled = [
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
              ];
            };

            shell = {
              screenshot = {
                annotate = true;
              };
            };

            sysmon = {
              enabled = true;
            };

            theme = {
              bultin = "Catppuccin";
              custom_palette = "stylix";
              mode = "dark";
              source = "custom";
            };

            wallpaper = {
              automation.enable = true;
              directory = "${config.home.homeDirectory}/.config/wallpapers";
            };

            weather = {
              enabled = true;
              unit = "metric";
            };

            widget = {
              workspaces = {
                hide_when_empt = true;
                scale = 1.2;
                style = "focus_hint";
              };
            };
          };

          enable = true;
        };

        stylix.targets = {
          noctalia.enable = true;
        };
      };
  };

}
