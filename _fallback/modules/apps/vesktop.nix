{ inputs, ... }: {
  flake.homeModules.vesktop = { ... }: {
    imports = [ inputs.nixcord.homeModules.nixcord ];
    programs.nixcord = {
      enable = true;
      discord = {
        enable = false;
        krisp.enable = true;
      };
      vesktop.enable = true;
      config.plugins = {
        hideMedia.enable = true;
        ignoreActivities = {
          enable = true;
          ignorePlaying = false;
        };
      };
      quickCss = "body { --font-primary: monospace; }";
      config.useQuickCss = true;
    };
  };
}
