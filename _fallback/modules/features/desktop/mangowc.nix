{ inputs, self, ... }: {

  flake.homeModules.mangowc = { config, ... }: {

    home.file.".config/mango" = {
      source = config.lib.file.mkOutOfStoreSymlink "/home/artifex/.dotfiles/config/mango";
      recursive = true;
    };

  };

  flake.nixosModules.mangowc = { config, ... }: {
    imports = [
      inputs.mangowm.nixosModules.mango
    ];

    home-manager.users.${config.preferences.user.name} = {
      imports = with self.homeModules; [
        mangowc
      ];
    };

    programs.mango.enable = true;

  };
}
