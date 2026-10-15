# Noctalia Desktop Shell Leaf Aspect
{
  core,
  den,
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs = {
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  den.aspects.desktop.noctalia = {
    nixos =
      { pkgs, ... }:
      {
        imports = lib.optionals (inputs ? noctalia) [
          inputs.noctalia.nixosModules.default
        ];

        programs.noctalia = lib.mkIf (inputs ? noctalia) {
          enable = true;
          recommendedServices.enable = true;
        };

        environment.systemPackages = with pkgs; [ gpu-screen-recorder ];
      };

    homeManager =
      { config, ... }:
      {
        stylix.targets = {
          noctalia.enable = true;
        };

        programs.noctalia = lib.mkIf (inputs ? noctalia) {
          enable = true;

          settings = {
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
  };

}
