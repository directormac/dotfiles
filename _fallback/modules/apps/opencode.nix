{ self, ... }: {

  flake.homeModules.opencode = {

    programs.opencode = {
      enable = true;
    };

  };

  flake.nixosModules.opencode = { config, ... }: {

    home-manager.users.${config.preferences.user.name} = {
      imports = with self.homeModules; [
        opencode
      ];
    };
  };
}
