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
      nixcord.enable = true;
      vencord.enable = true;
      vesktop = {
        enable = true;
        colors = {
          override = {
            base0B = "cba6f7";
          };
        };
      };
    };

  };
}
