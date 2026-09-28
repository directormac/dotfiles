{ self, ... }: {

  flake.homeModules.opencode = {

    programs.opencode = {
      enable = true;
    };

  };

  flake.nixosModules.opencode = { pkgs, config, ... }: {

    home-manager.users.${config.preferences.user.name} = {
      imports = with self.homeModules; [
        opencode
      ];
    };

    environment.systemPackages = with pkgs; [
      opencode
      opencode-desktop
    ];
  };
}
