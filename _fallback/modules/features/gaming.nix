{ self, ... }: {

  flake.homeModules.gaming = { pkgs, ... }: {

  };

  flake.nixosModules.gaming = { pkgs, config, ... }: {

    home-manager.users.${config.preferences.user.name} = {
      imports = [
        self.homeModules.zsh
      ];
    };

  };
}
