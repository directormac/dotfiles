{ self, ... }: {

  flake.homeModules.kitty = { pkgs, config, ... }: {

    home.file.".config/kitty" = {
      source = config.lib.file.mkOutOfStoreSymlink "/home/artifex/.dotfiles/config/kitty";
      recursive = true;
    };

    home.packages = with pkgs; [
      kitty
    ];

    # programs.kitty = {
    #   enable = true;
    # };

  };

  flake.nixosModules.kitty = { config, ... }: {

    home-manager.users.${config.preferences.user.name} = {
      imports = with self.homeModules; [
        kitty
      ];
    };

  };
}
