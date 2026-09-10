{
  self,
  inputs,
  ...
}:
  let
  kittyModule =
    {
      config,
      lib,
      ...
    }:
    {
      options = {
        shell = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
        dynamicMode = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "If true, use an impure config file from the home directory for hot-reloading.";
        };
        dynamicConfigPath = lib.mkOption {
          type = lib.types.str;
          default = "$HOME/.config/kitty/kitty.conf";
        };
      };

      config = {
        appendFlag = lib.mkAfter (
          lib.optionals config.dynamicMode [
            "--config"
            config.dynamicConfigPath
          ]
          ++ lib.optionals (config.shell != "") [ config.shell ]
        );

        keybindings = {
          "alt+1" = "goto_tab 1";
          "alt+2" = "goto_tab 2";
          "alt+3" = "goto_tab 3";
          "alt+4" = "goto_tab 4";
          "alt+5" = "goto_tab 5";
          "alt+6" = "goto_tab 6";
          "alt+7" = "goto_tab 7";
          "alt+8" = "goto_tab 8";
          "alt+9" = "goto_tab 9";
          "ctrl+shift+w" = "close_tab";
          "ctrl+t" = "new_tab_with_cwd";
          "ctrl+shift+t" = "new_tab";
        };

        settings = {
          enable_audio_bell = "no";
          font_size = 15;
          font_family = "Fira Mono Nerd Font";
          cursor_text_color = "background";
          # hide_window_decorations = "yes";
          allow_remote_control = "yes";
          shell_integration = "enabled";
          cursor_trail = 3;
          cursor_trail_decay = "0.1 0.4";
          cursor_trail_color = "#94e2d5";
          background = self.theme.base00;
          foreground = self.theme.base07;
          cursor = self.theme.base07;
          selection_foreground = self.theme.base02;
          selection_background = self.theme.base01;
          active_tab_foreground = self.theme.base0B;
          active_tab_background = self.theme.base03;
          inactive_tab_background = self.theme.base01;
          color0 = self.theme.base00;
          color8 = self.theme.base02;
          color1 = self.theme.base08;
          color9 = self.theme.base08;
          color2 = self.theme.base0B;
          color10 = self.theme.base0B;
          color3 = self.theme.base0A;
          color11 = self.theme.base0A;
          color4 = self.theme.base0D;
          color12 = self.theme.base0D;
          color5 = self.theme.base0E;
          color13 = self.theme.base0E;
          color6 = self.theme.base0C;
          color14 = self.theme.base0C;
          color7 = self.theme.base03;
          color15 = self.theme.base03;
        }
        // lib.optionalAttrs (config.shell != "") {
          inherit (config) shell;
        };

      };
    };

in
{
  flake.wrappersModules.kitty = kittyModule;

  perSystem = { pkgs, ... }: {

    packages.kitty =
      inputs.wrappers.wrappers.kitty.wrap {
        inherit pkgs;
        imports = [ kittyModule ];
      };

    packages.kittyDynamic =
      inputs.wrappers.wrappers.kitty.wrap {
        inherit pkgs;
        dynamicMode = true;
        imports = [ kittyModule ];
      };
  };
}
