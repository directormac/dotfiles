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

        xdg.configFile."dfiles/bookmarks.json" = lib.mkIf (inputs ? dfiles) {
          force = true;
          source =
            let
              jsonFormat = pkgs.formats.json { };
              userDirs = config.xdg.userDirs;
              gtkBookmarks = config.gtk.gtk3.bookmarks;

              parseGtkBookmark =
                line:
                let
                  raw = lib.removePrefix "file://" line;
                  parts = lib.splitString " " raw;
                  path = builtins.head parts;
                  labelParts = builtins.tail parts;
                  label = if labelParts != [ ] then lib.concatStringsSep " " labelParts else builtins.baseNameOf path;
                in
                {
                  inherit path label;
                };

              stdDirs = [
                {
                  path = "recent:///";
                  label = "recent";
                }
                {
                  path = config.home.homeDirectory;
                  label = builtins.baseNameOf config.home.homeDirectory;
                }
              ]
              ++ lib.optional (userDirs.desktop != null) {
                path = userDirs.desktop;
                label = "Desktop";
              }
              ++ lib.optional (userDirs.documents != null) {
                path = userDirs.documents;
                label = "Documents";
              }
              ++ lib.optional (userDirs.download != null) {
                path = userDirs.download;
                label = "Downloads";
              }
              ++ lib.optional (userDirs.music != null) {
                path = userDirs.music;
                label = "Music";
              }
              ++ lib.optional (userDirs.pictures != null) {
                path = userDirs.pictures;
                label = "Pictures";
              }
              ++ lib.optional (userDirs.videos != null) {
                path = userDirs.videos;
                label = "Videos";
              }
              ++ lib.optional (userDirs.publicShare != null) {
                path = userDirs.publicShare;
                label = "Public";
              }
              ++ lib.optional (userDirs.templates != null) {
                path = userDirs.templates;
                label = "Templates";
              }
              ++ (lib.mapAttrsToList (_: path: {
                inherit path;
                label = builtins.baseNameOf path;
              }) (userDirs.extraConfig or { }));

              customBookmarks = builtins.map parseGtkBookmark gtkBookmarks;

              allCandidates =
                stdDirs
                ++ customBookmarks
                ++ [
                  {
                    path = "trash:///";
                    label = "trash";
                  }
                ];

              dedup =
                items:
                let
                  step =
                    acc: item:
                    if builtins.elem item.path acc.seen then
                      acc
                    else
                      {
                        seen = acc.seen ++ [ item.path ];
                        list = acc.list ++ [ (item // { icon = item.icon or ""; }) ];
                      };
                in
                (builtins.foldl' step {
                  seen = [ ];
                  list = [ ];
                } items).list;
            in
            jsonFormat.generate "dfiles-bookmarks.json" {
              version = 2;
              bookmarks = dedup allCandidates;
            };
        };

        stylix.targets = {
          dank-calendar.enable = lib.mkDefault true;
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
