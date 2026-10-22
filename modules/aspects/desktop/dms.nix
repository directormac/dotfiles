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
      url = "github:duxlabs-dev/dux-calendar";
    };

    danksearch = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:duxlabs-dev/dux-search";
    };

    dfiles = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:duxlabs-dev/dux-files";
    };

    dgop = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:duxlabs-dev/dux-gop";
    };

    dms = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:duxlabs-dev/dux-shell";
    };

    dms-plugin-registry.url = "github:duxlabs-dev/dux-plugin-registry";
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
          ])
          ++ [
            # dmenu compatibility wrapper backed by DMS
            (pkgs.writeShellScriptBin "dmenu" ''
              exec dms dmenu "$@"
            '')
          ];

        security.pam.services.dankshell = { };
      };

    homeManager =
      { config, pkgs, ... }:
      let
        dmsDir = ../../../config/DankMaterialShell;
        dmsFiles = if builtins.pathExists dmsDir then builtins.readDir dmsDir else { };
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
              ".config/dms/${name}".source = config.lib.dots.link "DankMaterialShell/${name}";
            };
      in
      {
        home.file = lib.concatMapAttrs linkDank dmsFiles;

        imports =
          (lib.optionals (inputs ? dms) [
            inputs.dms.homeModules.dank-material-shell
          ])
          ++ (lib.optionals (inputs ? dfiles) [
            inputs.dfiles.homeModules.dux-files
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
          enableClipboardPaste = true;
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
            dankRssWidget.enable = true;
            dankStickerSearch.enable = true;
            dankVault.enable = true;
            emojiLauncher.enable = true;

            quickCapture = {
              enable = true;

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
            };

            voxtypeActivityOverlay.enable = true;
          };
        };

        programs.dsearch = lib.mkIf (inputs ? danksearch) {
          enable = true;
        };

        programs.dux-files = lib.mkIf (inputs ? dfiles) {
          enable = true;

          settings = {
            vimKeys = true;
          };

          portal = {
            enable = true;
            preferred = false;
          };

          systemd = {
            enable = true;
          };
        };

        stylix.targets = {
          dank-calendar.enable = lib.mkDefault true;
        };

        xdg.configFile."dfiles/bookmarks.json" = lib.mkIf (inputs ? dfiles) {
          force = true;

          source =
            let
              allCandidates =
                stdDirs
                ++ customBookmarks
                ++ [
                  {
                    label = "trash";
                    path = "trash:///";
                  }
                ];
              customBookmarks = map parseGtkBookmark gtkBookmarks;
              dedup =
                items:
                let
                  step =
                    acc: item:
                    if builtins.elem item.path acc.seen then
                      acc
                    else
                      {
                        list = acc.list ++ [ (item // { icon = item.icon or ""; }) ];
                        seen = acc.seen ++ [ item.path ];
                      };
                in
                (builtins.foldl' step {
                  list = [ ];
                  seen = [ ];
                } items).list;
              gtkBookmarks = config.gtk.gtk3.bookmarks;
              jsonFormat = pkgs.formats.json { };
              parseGtkBookmark =
                line:
                let
                  label = if labelParts != [ ] then lib.concatStringsSep " " labelParts else baseNameOf path;
                  labelParts = builtins.tail parts;
                  parts = lib.splitString " " raw;
                  path = builtins.head parts;
                  raw = lib.removePrefix "file://" line;
                in
                {
                  inherit path label;
                };
              stdDirs = [
                {
                  label = "recent";
                  path = "recent:///";
                }
                {
                  label = builtins.baseNameOf config.home.homeDirectory;
                  path = config.home.homeDirectory;
                }
              ]
              ++ lib.optional (userDirs.desktop != null) {
                label = "Desktop";
                path = userDirs.desktop;
              }
              ++ lib.optional (userDirs.documents != null) {
                label = "Documents";
                path = userDirs.documents;
              }
              ++ lib.optional (userDirs.download != null) {
                label = "Downloads";
                path = userDirs.download;
              }
              ++ lib.optional (userDirs.music != null) {
                label = "Music";
                path = userDirs.music;
              }
              ++ lib.optional (userDirs.pictures != null) {
                label = "Pictures";
                path = userDirs.pictures;
              }
              ++ lib.optional (userDirs.videos != null) {
                label = "Videos";
                path = userDirs.videos;
              }
              ++ lib.optional (userDirs.publicShare != null) {
                label = "Public";
                path = userDirs.publicShare;
              }
              ++ lib.optional (userDirs.templates != null) {
                label = "Templates";
                path = userDirs.templates;
              }
              ++ (lib.mapAttrsToList (_: path: {
                inherit path;
                label = builtins.baseNameOf path;
              }) (userDirs.extraConfig or { }));
              userDirs = config.xdg.userDirs;
            in
            jsonFormat.generate "dfiles-bookmarks.json" {
              bookmarks = dedup allCandidates;
              version = 2;
            };
        };
      };

    persistHome.directories = [
      ".config/danksearch"
      ".config/dfiles"
      ".config/dms"
      ".local/share/dankcal"
      ".local/state/dfiles"
      ".local/state/dms"
      ".local/state/dankcal"
    ];
  };

}
