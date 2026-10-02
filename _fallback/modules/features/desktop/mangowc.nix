{ inputs, self, ... }: {

  # Reference https://mangowm.github.io/docs/nix-options
  flake.homeModules.mangowc = { config, ... }: {

    wayland.windowManager.mango = {
      enable = true;
      systemd = {
        enable = true;
        xdgAutostart = true;
        variables = [
          "--all"
        ];
      };
    };

    home.file.".config/mango" = {
      source = config.lib.file.mkOutOfStoreSymlink "/home/artifex/.dotfiles/config/mango";
      recursive = true;
    };

  };

  flake.nixosModules.mangowc = { config, ... }: {
    imports = [
      inputs.mangowm.nixosModules.mango
      self.nixosModules.noctalia
    ];

    home-manager.users.${config.preferences.user.name} = {
      imports = [
        inputs.mangowm.hmModules.mango
        self.homeModules.mangowc
      ];
    };

    programs.mango.enable = true;

  };
}
