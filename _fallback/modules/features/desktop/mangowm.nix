{ inputs, self, ... }: {

  # Reference https://mangowm.github.io/docs/nix-options
  flake.homeModules.mangowm = { config, ... }: {

    wayland.windowManager.mango = {
      enable = true;
      systemd = {
        enable = true;
        xdgAutostart = true;
        variables = [
          "--all"
        ];
        extraCommands = [
          "systemctl --user reset-failed"
          "systemctl --user start mango-session.target"
        ];
        autostart_sh =
          # sh
          ''
            noctalia &
            # /usr/lib/xdg-desktop-portal-wlr &
            wl-clip-persist --clipboard regular --reconnect-tries 0 &
            wl-paste --type text --watch cliphist store &
          '';
      };
    };

    home.file.".config/mango" = {
      source = config.lib.file.mkOutOfStoreSymlink "/home/artifex/.dotfiles/config/mango";
      recursive = true;
    };

  };

  flake.nixosModules.mangowm = { config, ... }: {
    imports = [
      inputs.mangowm.nixosModules.mango
      self.nixosModules.noctalia
    ];

    home-manager.users.${config.preferences.user.name} = {
      imports = [
        inputs.mangowm.hmModules.mango
        self.homeModules.mangowm
      ];
    };

    programs.mango.enable = true;

  };
}
