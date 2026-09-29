{ self, ... }: {
  flake.homeModules.bitwarden = { config, ... }: {

    programs.rbw = {
      enable = true;
      settings = {
        email = config.preferences.user.email;
      };
    };

  };

  flake.nixosModules.bitwarden = { pkgs, config, ... }: {

    home-manager.users.${config.preferences.user.name} = {
      imports = with self.homeModules; [
        bitwarden
      ];
    };

    environment.systemPackages = [ pkgs.bitwarden-desktop ];

  };
}
