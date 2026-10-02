{ inputs, ... }: {
  flake.homeModules.vesktop = { ... }: {
    imports = [ inputs.nixcord.homeModules.nixcord ];
    programs.nixcord = {
      enable = true;
      # discord = {
      #   enable = false;
      #   krisp.enable = true;
      # };
      discord.enable = false;
      vesktop.enable = true;
      config.plugins = {
        betterFolders.enable = true;
        biggerStreamPreview.enable = true;
        fakeNitro.enable = true;
        hideMedia.enable = true;
        pictureInPicture.enable = true;
        showHiddenChannels.enable = true;
        # showMeYourName.enabled = true;
        # webContextMenus.enabled = true;
        # webKeybinds.enabled = true;
        # webScreenShareFixes.enabled = true;
      };
      quickCss = "body { --font-primary: monospace; }";
      config.useQuickCss = true;
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
}
