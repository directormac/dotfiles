{ self, ... }: {

  # flake.homeModules.bitwarden = { config, ... }: {
  #
  #   programs.rbw = {
  #     enable = true;
  #   };
  #
  # };

  flake.nixosModules.bitwarden = { pkgs, config, ... }: {

    home-manager.users.${config.preferences.user.name} = {

      # imports = with self.homeModules; [
      #   bitwarden
      # ];

      programs.rbw.enable = true;
      programs.rbw.settings.email = config.preferences.user.email;
    };

    environment.systemPackages = [ pkgs.bitwarden-desktop ];

  };
}
