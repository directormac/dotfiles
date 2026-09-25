{
  inputs,
  self,
  ...
}:
{

  flake.homeModules.dms =
    { lib, config, ... }:
    let

      # Define where your flake lives on the live filesystem
      flakePath = "${config.home.homeDirectory}/.dotfiles";

      linkDank =
        name: type:
        if name == "plugins" then
          { }
        else
          {
            ".config/DankMaterialShell/${name}".source =
              config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/DankMaterialShell/${name}";
          };

    in

    {
      home.file = {

      }
      # This merges the filtered directory directly into your home.file
      // lib.concatMapAttrs linkDank (builtins.readDir ../../../../config/DankMaterialShell);

    };

  flake.nixosModules.dms = { config, pkgs, ... }: {
    imports = [
      inputs.dms.nixosModules.dank-material-shell
      inputs.dms-plugin-registry.nixosModules.default
      inputs.dankcalendar.nixosModules.default

    ];

    home-manager.users.${config.preferences.user.name} = {
      imports = [
        self.homeModules.dms
      ];
    };

    programs = {
      dsearch = {
        enable = true;

        # Systemd service configuration
        systemd = {
          enable = true; # Enable systemd user service
          target = "default.target"; # Start with user session
        };
      };

      dank-calendar = {
        enable = true;
        systemd = {
          enable = true;
          target = "default.target";
        };
      };

      # https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/programs/wayland/dms-shell.nix
      dank-material-shell = {
        enable = true;

        # systemd = {
        #   enable = true; # Systemd service for auto-start
        #   restartIfChanged = true; # Auto-restart dms.service when dank-material-shell changes
        # };

        # Core features
        enableSystemMonitoring = true;
        enableVPN = true; # VPN management widget
        enableDynamicTheming = true; # Wallpaper-based theming (matugen)
        enableAudioWavelength = true; # Audio visualizer (cava)
        enableCalendarEvents = true; # Calendar integration (khal)

        # See https://danklinux.com/docs/dankmaterialshell/nixos-flake#plugins
        plugins = {
          #   # Simply enable plugins by their ID (from the registry)
          dankActions.enable = true;
          dankGifSearch.enable = true;
          dankHooks.enable = true;
          dankKDEConnect.enable = true;
          dankLauncherKeys.enable = true;
          dankPomodoroTimer.enable = true;
          dankStickerSearch.enable = true;
          dankNotepadModule.enable = true;

          # https://github.com/hthienloc/dms-plugins/blob/main/quickCapture/docs/index.md
          quickCapture.enable = true;
          emojiLauncher.enable = true;
          ambientSound.enable = true;
          screenkey.enable = true;

          amdGpuMonitor.enable = true;

          # Desktop
          dankRssWidget.enable = true;
          pureLyrics.enable = true;
          cavaVisualizer.enable = true;
        };
      };

      kdeconnect = {
        enable = true;
        package = pkgs.valent;
      };
    };

    environment.systemPackages = with pkgs; [
      inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default

      matugen
      xwayland-satellite
      valent

      gpu-screen-recorder

      amdgpu_top
    ];
  };
}
