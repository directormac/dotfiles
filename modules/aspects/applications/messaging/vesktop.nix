# Vesktop (Nixcord) Discord Client Aspect
{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    nixcord = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:4evy/nixcord";
    };
  };

  den.aspects.applications.messaging.vesktop = {
    homeManager =
      { ... }:
      {
        imports = lib.optionals (inputs ? nixcord) [
          inputs.nixcord.homeModules.nixcord
        ];

        programs.nixcord = lib.mkIf (inputs ? nixcord) {
          enable = true;

          config.plugins = {
            biggerStreamPreview.enable = true;
            fakeNitro.enable = true;
            hideMedia.enable = true;
            pictureInPicture.enable = true;
            showHiddenChannels.enable = true;
          };

          config.useQuickCss = true;
          discord.enable = false;
          quickCss = "body { --font-primary: monospace; }";
          vesktop.enable = true;
        };

        stylix.targets = {
          nixcord = {
            enable = true;

            extraCss = ''
              /* Override Stylix mapping blurple to base0B (green) -> use Mauve */
              :root {
                --blurple-50: var(--base0D) !important;
                --button-positive-background: var(--base0D) !important;
              }
              path[fill^="rgba(88, 101, 242, 1)"] {
                fill: var(--base0D) !important;
              }
            '';
          };

          vencord.enable = true;
          vesktop.enable = true;
        };
      };

    persistHome.directories = [
      ".config/vesktop"
      ".config/Vencord"
    ];
  };
}
