{
  inputs,
  self,
  ...
}:
{
  # flake.nixosModules.niri = { pkgs, lib, ... }: {
  #   programs.niri = {
  #     enable = true;
  #     package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
  #   };
  # };

  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
    };
  };

  flake.wrappersModules.niri =
    {
      config,
      lib,
      pkgs,
      self',
      ...
    }:
    {
      options = {
        terminal = lib.mkOption {
          type = lib.types.str;
          default = "ghostty";
        };
        fileManager = lib.mkOption {
          type = lib.types.str;
          default = "yazi";
        };
        dynamicMode = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "If true, use an impure config file from the home directory for hot-reloading.";
        };
        dynamicConfigPath = lib.mkOption {
          type = lib.types.str;
          default = "$HOME/.config/niri/config.kdl";
        };
      };

      config = {
        "config.kdl".path = lib.mkIf config.dynamicMode config.dynamicConfigPath;
        disableConfigValidation = lib.mkIf config.dynamicMode true;
        disableConfigHotReload = lib.mkIf config.dynamicMode true;

        settings =
          let
            # startNoctaliaExe = lib.getExe self.packages.${config.pkgs.stdenv.hostPlatform.system}.start-noctalia-shell;
            # noctaliaExe = lib.getExe self.packages.${config.pkgs.stdenv.hostPlatform.system}.noctalia-shell;
            noctaliaExe = lib.getExe self'.packages.noctalia;
          in
          {
            prefer-no-csd = [ ];

            input = {
              focus-follows-mouse = [ ];

              keyboard = {
                numlock = [ ];
                xkb = {
                  layout = "us";

                  options = "caps:hyper";
                };
                repeat-rate = 40;
                repeat-delay = 250;
              };

              touchpad = {
                natural-scroll = [ ];
                tap = [ ];
              };

              mouse = {
                accel-profile = "flat";
              };
            };

            binds = {
              "Mod+Shift+Slash".show-hotkey-overlay = [ ];

              "Mod+Return".spawn = config.terminal;
              "Mod+Shift+Return".spawn = [
                config.terminal
                "--class=floating.ghostty"
              ];
              "Mod+E".spawn = [
                config.terminal
                "--class=floating.yazi"
                "-e"
                config.fileManager
              ];

              "Mod+Shift+Escape".quit = [ ];
              "Mod+Escape".toggle-overview = [ ];
              # "Mod+Hyper".toggle-overview = [ ];
              "Mod+Q".close-window = [ ];
              "Mod+F".maximize-column = [ ];
              "Mod+G".fullscreen-window = [ ];
              "Mod+V".toggle-window-floating = [ ];
              "Mod+Shift+V".switch-focus-between-floating-and-tiling = [ ];
              "Mod+C".center-column = [ ];
              "Mod+R".switch-preset-column-width = [ ];
              "Mod+BracketLeft".consume-or-expel-window-left = [ ];
              "Mod+BracketRight".consume-or-expel-window-right = [ ];

              "Mod+Ctrl+D".focus-workspace-down = [ ];
              "Mod+Ctrl+U".focus-workspace-up = [ ];

              # Or if you prefer pure Vim home-row keys for workspaces:
              "Mod+Ctrl+N".focus-workspace-down = [ ];
              "Mod+Ctrl+P".focus-workspace-up = [ ];

              "Mod+H".focus-column-left = [ ];
              "Mod+L".focus-column-right = [ ];
              "Mod+K".focus-window-up = [ ];
              "Mod+J".focus-window-down = [ ];

              "Mod+Left".focus-column-left = [ ];
              "Mod+Right".focus-column-right = [ ];
              "Mod+Up".focus-window-up = [ ];
              "Mod+Down".focus-window-down = [ ];

              "Mod+Shift+H".move-column-left = [ ];
              "Mod+Shift+L".move-column-right = [ ];
              "Mod+Shift+K".move-window-up = [ ];
              "Mod+Shift+J".move-window-down = [ ];

              "Mod+1".focus-workspace = "w0";
              "Mod+2".focus-workspace = "w1";
              "Mod+3".focus-workspace = "w2";
              "Mod+4".focus-workspace = "w3";
              "Mod+5".focus-workspace = "w4";
              "Mod+6".focus-workspace = "w5";
              "Mod+7".focus-workspace = "w6";
              "Mod+8".focus-workspace = "w7";
              "Mod+9".focus-workspace = "w8";
              "Mod+0".focus-workspace = "w9";

              "Mod+Shift+1".move-column-to-workspace = "w0";
              "Mod+Shift+2".move-column-to-workspace = "w1";
              "Mod+Shift+3".move-column-to-workspace = "w2";
              "Mod+Shift+4".move-column-to-workspace = "w3";
              "Mod+Shift+5".move-column-to-workspace = "w4";
              "Mod+Shift+6".move-column-to-workspace = "w5";
              "Mod+Shift+7".move-column-to-workspace = "w6";
              "Mod+Shift+8".move-column-to-workspace = "w7";
              "Mod+Shift+9".move-column-to-workspace = "w8";
              "Mod+Shift+0".move-column-to-workspace = "w9";

              "Mod+Ctrl+H".set-column-width = "-5%";
              "Mod+Ctrl+L".set-column-width = "+5%";
              "Mod+Ctrl+J".set-window-height = "-5%";
              "Mod+Ctrl+K".set-window-height = "+5%";

              "Mod+WheelScrollDown".focus-column-left = [ ];
              "Mod+WheelScrollUp".focus-column-right = [ ];
              "Mod+Ctrl+WheelScrollDown".focus-workspace-down = [ ];
              "Mod+Ctrl+WheelScrollUp".focus-workspace-up = [ ];
              "Mod+Ctrl+Page_Down".move-column-to-workspace-down = [ ];
              "Mod+Ctrl+Page_Up".move-column-to-workspace-up = [ ];

              "Mod+Space".spawn-sh = "${lib.getExe pkgs.noctalia} msg panel-toggle launcher";
              "Mod+D".spawn-sh = "${lib.getExe self'.packages.menu1}";
              "Mod+S".spawn-sh = "${lib.getExe pkgs.noctalia} msg panel-toggle control-center";
              "Mod+Comma".spawn-sh = "${lib.getExe pkgs.noctalia} msg settings-toggle";

              "Mod+grave".focus-workspace-previous = [ ];
              "Alt+Tab".spawn-sh = "${lib.getExe pkgs.noctalia} msg window-switcher";

              "XF86AudioRaiseVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
              "XF86AudioLowerVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";
              "XF86AudioMute".spawn-sh = "wpctl set-mute -l  @DEFAULT_AUDIO_SINK@";

              # "XF86AudioRaiseVolume".spawn-sh = "${lib.getExe pkgs.noctalia}  msg volume-up";
              # "XF86AudioLowerVolume".spawn-sh = "${lib.getExe pkgs.noctalia}  msg volume-down";
              # "XF86AudioMute".spawn-sh = "${lib.getExe pkgs.noctalia}  msg volume-mute";

              "Mod+Ctrl+S".spawn-sh =
                "${lib.getExe config.pkgs.grim} -l 0 - | ${config.pkgs.wl-clipboard}/bin/wl-copy";

              "Mod+Shift+E".spawn-sh =
                "${config.pkgs.wl-clipboard}/bin/wl-paste | ${lib.getExe config.pkgs.swappy} -f -";

              "Mod+Shift+S".spawn-sh = lib.getExe (
                config.pkgs.writeShellApplication {
                  name = "screenshot";
                  text = ''
                    ${lib.getExe config.pkgs.grim} -g "$(${lib.getExe config.pkgs.slurp} -w 0)" - \
                    | ${config.pkgs.wl-clipboard}/bin/wl-copy
                  '';
                }
              );

            };

            # hotkey-overlay-title = "Artifex's Niri Hotkeys";

            hotkey-overlay = {
              skip-at-startup = [ ];
              hide-not-bound = [ ];
            };

            screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

            cursor = {
              hide-when-typing = [ ];
              hide-after-inactive-ms = 1000;
            };

            layout = {
              gaps = 3;
              # default-column-width = {
              #   proportion = 1.0;
              # };
              center-focused-column = "never";
              # always-center-single-column = [ ];
              focus-ring = {
                width = 1;
              };
              border = {
                off = [ ];
                width = 0;
              };
            };

            workspaces =
              let
                settings = {
                  layout.gaps = 5;
                };
              in
              {
                "w0" = settings;
                "w1" = settings;
                "w2" = settings;
                "w3" = settings;
                "w4" = settings;
                "w5" = settings;
                "w6" = settings;
                "w7" = settings;
                "w8" = settings;
                "w9" = settings;
              };

            xwayland-satellite.path = lib.getExe config.pkgs.xwayland-satellite;

            spawn-at-startup = [
              noctaliaExe
              (lib.getExe (config.pkgs.writeShellScriptBin "start-zen" "exec zen-browser"))
              (lib.getExe (
                config.pkgs.writeShellScriptBin "startup-ghostty" ''
                  exec ghostty --class=startup.fastfetch -e sh -c 'fastfetch; exec $SHELL'
                ''
              ))
            ];

            window-rules = [
              {
                matches = [
                  { app-id = "startup.fastfetch"; }
                  { app-id = ".*floating.*"; }
                ];
                open-floating = true;
              }
              {
                matches = [
                  { app-id = "zen$"; }
                ];
                open-maximized = true;
              }
              {
                matches = [
                  {
                    app-id = "firefox$";
                    title = "^Picture-in-Picture$";
                  }
                ];
                open-floating = true;
              }
              {
                matches = [
                  {
                    is-floating = true;
                  }
                ];
                shadow = {
                  on = [ ];
                };
              }
            ];
          };
      };
    };

  perSystem = { pkgs, self', ... }: {
    # packages.niri = inputs.wrappers.wrappers.niri.wrap {
    #   inherit pkgs;
    #   imports = [
    #     self.wrappersModules.niri
    #     { _module.args.self' = self'; }
    #   ];
    # };
    packages.niri = inputs.wrappers.wrappers.niri.wrap {
      inherit pkgs;
      # dynamicMode = false;
      imports = [
        self.wrappersModules.niri
        { _module.args.self' = self'; }
      ];
    };
  };
}
