{
  flake.nixosModules.bitwarden = { pkgs, config, ... }: {

    home-manager.users.${config.preferences.user.name} = {

      home.packages = with pkgs; [
        bitwarden-desktop
        bitwarden-cli
        bws
      ];

      programs.rbw.enable = true;
      programs.rbw.settings.email = config.preferences.user.email;

    };

    # environment.systemPackages = [ pkgs.bitwarden-desktop ];
  };
}
