# Shaders
# https://github.com/0xhckr/ghostty-shaders/blob/main/shader.sh
# https://catskull.net/fun-with-ghostty-shaders.html
{ inputs, self, ... }: {

  flake.homeModules.ghostty = { pkgs, config, ... }: {

    home.file.".config/ghostty" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.preferences.dotsConfigPath}/ghostty";
      recursive = true;
    };

    home.file.".local/bin/gshader" = {
      text = ''
        #!/usr/bin/env bash
        exec ${config.preferences.dotsConfigPath}/ghostty/shader.sh "$@"
      '';
      executable = true;
    };

    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      installBatSyntax = true;
      installVimSyntax = true;
      # systemd = {};
    };
  };

  flake.nixosModules.ghostty = { pkgs, config, ... }: {

    home-manager.users.${config.preferences.user.name} = {
      imports = with self.homeModules; [
        ghostty
      ];
    };

    # Ghostty tip
    nixpkgs.overlays = [
      inputs.ghostty.overlays.default
    ];

    environment.systemPackages = with pkgs; [
      ghostty
    ];

  };
}
