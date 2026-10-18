# DankMaterialShell (DMS) Desktop Environment Leaf Aspect
{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    dankcalendar = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:AvengeMedia/dankcalendar";
    };

    danksearch = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:AvengeMedia/danksearch";
    };

    dgop = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:AvengeMedia/dgop";
    };

    dms = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:AvengeMedia/DankMaterialShell";
    };

    dms-plugin-registry.url = "github:AvengeMedia/dms-plugin-registry";
  };

  den.aspects.desktop.dms = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages =
          (lib.optionals (inputs ? dgop) [
            inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default
          ])
          ++ (with pkgs; [
            matugen
            xwayland-satellite
            gpu-screen-recorder
            amdgpu_top
          ]);

        security.pam.services.dankshell = { };
      };

    homeManager =
      {
        config,
        user,
        ...
      }:
      let
        dmsDir = ../../../config/DankMaterialShell;
        dmsFiles = if builtins.pathExists dmsDir then builtins.readDir dmsDir else { };
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
        linkDank =
          name: _:
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
                config.lib.file.mkOutOfStoreSymlink "${dotsPath}/DankMaterialShell/${name}";
            };
      in
      {
        home.file = lib.concatMapAttrs linkDank dmsFiles;

        imports =
          (lib.optionals (inputs ? dms) [
            inputs.dms.homeModules.dank-material-shell
          ])
          ++ (lib.optionals (inputs ? danksearch) [
            inputs.danksearch.homeModules.default
          ])
          ++ (lib.optionals (inputs ? dankcalendar) [
            inputs.dankcalendar.homeModules.default
          ])
          ++ (lib.optionals (inputs ? dms-plugin-registry) [
            inputs.dms-plugin-registry.nixosModules.default
          ]);

        programs.dank-calendar = lib.mkIf (inputs ? dankcalendar) {
          enable = true;
        };

        programs.dank-material-shell = lib.mkIf (inputs ? dms) {
          enable = true;
          enableAudioWavelength = true;
          enableCalendarEvents = true;
          enableDynamicTheming = true;
          enableSystemMonitoring = true;
          enableVPN = true;
          managePluginSettings = true;

          plugins = {
            ambientSound.enable = true;
            amdGpuMonitor.enable = true;
            cavaVisualizer.enable = true;
            dankActions.enable = true;
            dankGifSearch.enable = true;
            dankHooks.enable = true;
            dankKDEConnect.enable = true;
            dankLauncherKeys.enable = true;
            dankNotepadModule.enable = true;
            dankPomodoroTimer.enable = true;
            dankRssWidget.enable = true;
            dankStickerSearch.enable = true;
            dankVault.enable = true;
            emojiLauncher.enable = true;
            pureLyrics.enable = true;

            quickCapture = {
              settings = {
                "delete_screenshots_on_close" = false;
                "doneAction" = "clipboard";
                "export_compress" = true;
                "export_format" = "png";
                "includeCursor" = false;
                "menuRightClickAction" = "copy";
                "recordingFormat" = "mp4";
                "recordingFramerate" = "60";
                "recordingQuality" = "very_high";
                "recordingScreenTarget" = "focused";
                "resetLastRegion" = true;
                "skipConfirm" = true;
              };

              enable = true;
            };

            screenkey.enable = true;
          };
        };

        programs.dsearch = lib.mkIf (inputs ? danksearch) {
          enable = true;
        };

        stylix.targets = {
          dank-calendar.enable = lib.mkDefault true;
        };
      };

    persistHome.directories = [
      ".config/danksearch"
      ".local/share/dankcal"
      ".local/state/DankMaterialShell"
      ".local/state/dankcal"
    ];
  };

}
