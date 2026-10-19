# Voxtype / Voxterm (Voice-to-text)
{
  lib,
  inputs,
  ...
}:
{
  den.aspects.applications.dev.ai.vox = {
    homeManager =
      { pkgs, ... }:
      let
        llmPkgs = pkgs.llm-agents or (inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system} or { });
      in
      {
        home.packages = [
          pkgs.wtype
        ]
        ++ lib.attrValues (
          lib.filterAttrs (_: v: v != null) {
            inherit (llmPkgs)
              voxterm
              ;
          }
        );

        services.voxtype = lib.mkIf (llmPkgs ? voxtype) {
          enable = true;

          settings = {
            audio = {
              feedback = {
                enabled = true;
                theme = "subtle";
                volume = 0.6;
              };
            };

            hotkey = {
              enabled = false; # Handled by Hyprland keybinding calling `voxtype record toggle`
            };

            osd = {
              enabled = false;
            };

            output = {
              fallback_to_clipboard = true;
              mode = "type";

              notification = {
                on_recording_start = true;
                on_recording_stop = true;
                on_transcription = true;
              };
            };

            whisper = {
              language = "en";
              model = "base.en";
            };
          };

          environment = {
            PATH = "${lib.makeBinPath [
              pkgs.wtype
              pkgs.wl-clipboard
              pkgs.coreutils
              pkgs.which
            ]}";
          };

          loadModels = [
            "base.en"
          ];

          package = llmPkgs.voxtype;
        };
      };

    persistHome.directories = [
      ".local/share/voxtype"
      ".config/voxtype"
      ".local/share/voxterm"
      ".config/voxterm"
    ];
  };
}
