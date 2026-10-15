# DankMaterialShell (DMS) Desktop Environment Leaf Aspect
{
  core,
  den,
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs = {
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms-plugin-registry.url = "github:AvengeMedia/dms-plugin-registry";
    dankcalendar = {
      url = "github:AvengeMedia/dankcalendar";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  den.aspects.desktop.dms = {
    nixos =
      { pkgs, ... }:
      {
        security.pam.services.dankshell = { };

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
      };

    homeManager =
      {
        config,
        user,
        ...
      }:
      let
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
        dmsDir = ../../../config/DankMaterialShell;
        dmsFiles = if builtins.pathExists dmsDir then builtins.readDir dmsDir else { };
      in
      {
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

        home.file = lib.concatMapAttrs linkDank dmsFiles;

        stylix.targets = {
          dank-calendar.enable = lib.mkDefault true;
        };

        programs.dank-material-shell = lib.mkIf (inputs ? dms) {
          enable = true;
          managePluginSettings = true;
          enableSystemMonitoring = true;
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
            dankNotepadModule.enable = true;
            dankVault.enable = true;
            emojiLauncher.enable = true;
            screenkey.enable = true;
            ambientSound.enable = true;
            amdGpuMonitor.enable = true;
            dankRssWidget.enable = true;
            pureLyrics.enable = true;
            cavaVisualizer.enable = true;
            quickCapture = {
              enable = true;
              settings = {
                "delete_screenshots_on_close" = false;
                "export_compress" = true;
                "export_format" = "png";
                "includeCursor" = false;
                "recordingFormat" = "mp4";
                "recordingFramerate" = "60";
                "recordingQuality" = "very_high";
                "recordingScreenTarget" = "focused";
                "resetLastRegion" = true;
                "skipConfirm" = true;
                "doneAction" = "clipboard";
                "menuRightClickAction" = "copy";
              };
            };
          };
        };

        programs.dsearch = lib.mkIf (inputs ? danksearch) {
          enable = true;
        };

        programs.dank-calendar = lib.mkIf (inputs ? dankcalendar) {
          enable = true;
        };
      };
  };

}
