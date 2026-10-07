{ self, ... }: {

  flake.homeModules.tuxedo =
    { config, ... }:
    {
      home.file.".config/tuxedo".source = config.lib.file.mkOutOfStoreSymlink ../../../config/tuxedo;
    };

  flake.nixosModules.tuxedo = { pkgs, config, ... }: {

    home-manager.users.${config.preferences.user.name} = {
      imports = with self.homeModules; [
        tuxedo
      ];
    };

    environment.systemPackages = with pkgs; [
      tuxedo
    ];

  };
}
