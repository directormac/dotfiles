{ self, ... }: {

  flake.homeModules.niri = { config, ... }: {

    home.file.".config/niri" = {
      source = config.lib.file.mkOutOfStoreSymlink "/home/artifex/.dotfiles/config/niri";
      recursive = true;
    };

  };

  flake.nixosModules.niri = { config, ... }: {
    programs.niri = {
      enable = true;
    };

    home-manager.users.${config.preferences.user.name} = {
      imports = with self.homeModules; [
        niri
      ];
    };

  };
}
