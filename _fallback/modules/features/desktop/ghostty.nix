# Shaders
# https://github.com/0xhckr/ghostty-shaders/blob/main/shader.sh
{ inputs, self, ... }: {

  flake.homeModules.ghostty = { pkgs, config, ... }: {

    home.file.".config/ghostty" = {
      source = config.lib.file.mkOutOfStoreSymlink "/home/artifex/.dotfiles/config/ghostty";
      recursive = true;
    };

    home.packages = with pkgs; [
      ghostty
    ];

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
