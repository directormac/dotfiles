{
  inputs,
  self,
  ...
}:
{

  flake.homeModules.dms =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let

      # Define where your flake lives on the live filesystem
      flakePath = "${config.home.homeDirectory}/.dotfiles";

      linkDank =
        name: type:
        if
          builtins.elem name [
            "plugins"
            "plugin_settings.json"
          ]
        then
          { }
        else
          {
            ".config/DankMaterialShell/${name}".source =
              config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/DankMaterialShell/${name}";
          };
    in

    {
      home.file =
        { }
        # This merges the filtered directory directly into your home.file
        // lib.concatMapAttrs linkDank (builtins.readDir ../../../../config/DankMaterialShell);

      imports = [
        inputs.dms.homeModules.dank-material-shell
        inputs.danksearch.homeModules.default
        inputs.dankcalendar.homeModules.default
        inputs.dms-plugin-registry.nixosModules.default
      ];

      # https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/programs/wayland/dms-shell.nix
      programs.dank-material-shell = {
        enable = true;

        managePluginSettings = true;

        enableSystemMonitoring = true;
        enableVPN = true; # VPN management widget
        enableDynamicTheming = true; # Wallpaper-based theming (matugen)
        enableAudioWavelength = true; # Audio visualizer (cava)
        enableCalendarEvents = true; # Calendar integration (khal)

        plugins = {
          # Example
          # DockerManager = {
          #   src = pkgs.fetchFromGitHub {
          #     owner = "LuckShiba";
          #     repo = "DmsDockerManager";
          #     rev = "v1.2.0";
          #     sha256 = "sha256-VoJCaygWnKpv0s0pqTOmzZnPM922qPDMHk4EPcgVnaU=";
          #   };
          #   settings = {
          #     someOption = "value";
          #   };
          # };
          # AnotherPlugin = {
          #   enable = true;
          #   src = pkgs.another-plugin;
          # };

          dankActions.enable = true;
          dankGifSearch.enable = true;
          dankHooks.enable = true;
          dankKDEConnect = {
            enable = true;
            # settings = {
            #   deviceImageMap = { }; # ported from repo plugin_settings.json
            # };
          };
          dankLauncherKeys = {
            enable = true;
            # settings = {
            #   noTrigger = false;
            #   providers = [ ];
            # };
          };
          dankPomodoroTimer.enable = true;
          dankStickerSearch.enable = true;
          dankNotepadModule.enable = true;

          dankVault.enable = true;

          emojiLauncher = {
            enable = true;
            # settings = {
            #   recentEmojis = "";
            # };
          };

          screenkey = {
            enable = true;
            # settings = {
            #
            # };
          };

          ambientSound.enable = true;
          amdGpuMonitor.enable = true;
          dankRssWidget.enable = true;
          pureLyrics.enable = true;
          cavaVisualizer.enable = true;

          # https://github.com/hthienloc/dms-plugins/blob/main/quickCapture/docs/index.md
          # https://github.com/hthienloc/dms-plugins/blob/main/quickCapture/docs/ipc-and-settings.md
          quickCapture = {
            enable = true;
            settings = {
              "delete_screenshots_on_close" = false;
              "export_compress" = true;
              "export_format" = "png"; # options: png, webp, jpg, pdf, ppm
              "includeCursor" = false;
              "recordingFormat" = "mp4";
              "recordingFramerate" = "60";
              "recordingQuality" = "very_high";
              "recordingScreenTarget" = "focused";
              "resetLastRegion" = true;
              "skipConfirm" = true;
            };
          };

        };
      };

      programs = {
        dsearch = {
          enable = true;

          # Systemd service configuration
          # systemd = {
          #   enable = true; # Enable systemd user service
          #   target = "default.target"; # Start with user session
          # };
        };

        dank-calendar = {
          enable = true;
          # systemd = {
          #   enable = true;
          #   target = "graphical-session.target";
          # };
        };

      };

    };

  flake.nixosModules.dms = { config, pkgs, ... }: {
    # imports = [
    #   inputs.dankcalendar.nixosModules.default
    # ];

    home-manager.users.${config.preferences.user.name} = {
      imports = [
        self.homeModules.dms
      ];
    };

    # programs = {
    #   dsearch = {
    #     enable = true;
    #
    #     # Systemd service configuration
    #     systemd = {
    #       enable = true; # Enable systemd user service
    #       target = "default.target"; # Start with user session
    #     };
    #   };
    #
    #   dank-calendar = {
    #     enable = true;
    #     systemd = {
    #       enable = true;
    #       target = "default.target";
    #     };
    #   };
    #
    #   # https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/programs/wayland/dms-shell.nix
    #
    # };

    environment.systemPackages = with pkgs; [
      inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default

      matugen
      xwayland-satellite

      gpu-screen-recorder

      amdgpu_top
    ];
  };
}
