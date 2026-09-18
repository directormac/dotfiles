{inputs, ...}: {
  flake-file.inputs = {
    dms.url = "github:AvengeMedia/DankMaterialShell";
    dms-plugin-registry.url = "github:AvengeMedia/dms-plugin-registry";
    dgop.url = "github:AvengeMedia/dgop";
    danksearch.url = "github:AvengeMedia/danksearch";
    dankcalendar.url = "github:AvengeMedia/dankcalendar";
  };

  den.aspects.desktop.dms = {
    nixos = {pkgs, ...}: {
      imports = [
        inputs.dms.nixosModules.dank-material-shell
        inputs.dms-plugin-registry.nixosModules.default
        inputs.dankcalendar.nixosModules.default
      ];

      programs = {
        dsearch = {
          enable = true;
          systemd = {
            enable = true;
            target = "default.target";
          };
        };

        dank-calendar = {
          enable = true;
          systemd = {
            enable = true;
            target = "default.target";
          };
        };

        dms-shell = {
          enable = true;
          # enableSystemMonitoring = true;
          enableVPN = true;
          enableDynamicTheming = true;
          enableAudioWavelength = true;
          enableCalendarEvents = true;

          plugins = {
            dankActions.enable = true;
            dankGifSearch.enable = true;
            dankHooks.enable = true;
            dankKDEConnect.enable = true;
            dankLauncherKeys.enable = true;
            dankPomodoroTimer.enable = true;
            dankStickerSearch.enable = true;
            quickCapture.enable = true;
            amdGpuMonitor.enable = true;
          };
        };
      };

      environment = {
        systemPackages = with pkgs; [
          inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default

          matugen
          xwayland-satellite
          quickshell
          cliphist

          # move to sddm later
          kdePackages.qtmultimedia
        ];
      };
    };
  };
}
