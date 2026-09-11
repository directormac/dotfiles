{inputs, ...}: {
  flake.nixosModules.dms = {pkgs, ...}: {
    imports = [
      inputs.dms.nixosModules.dank-material-shell
      inputs.dms-plugin-registry.nixosModules.default
      inputs.dankcalendar.nixosModules.default
    ];
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
          quickCapture.enable = true;
          amdGpuMonitor.enable = true;
          #
        };
      };
    };

    environment.systemPackages = [
      inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };

  perSystem = {pkgs, ...}: {
    packages.dms = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;

      runtimePkgs = [
        pkgs.matugen
        pkgs.xwayland-satellite

        # pkgs.amd_gputop
      ];

      package = pkgs.dms;
    };
  };
}
