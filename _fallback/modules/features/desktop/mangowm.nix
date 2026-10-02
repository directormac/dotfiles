{ inputs, self, ... }: {

  # Reference https://mangowm.github.io/docs/nix-options
  flake.homeModules.mangowm = { config, pkgs, ... }: {

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
      };
      autostart_sh =
        # sh
        ''
          noctalia &
          systemctl --user restart xdg-desktop-portal xdg-desktop-portal-wlr &
          wl-clip-persist --clipboard regular --reconnect-tries 0 &
          wl-paste --type text --watch cliphist store &
        '';
      extraConfig = ''
        source = ${config.home.homeDirectory}/.dotfiles/config/mango/config.conf
      '';
    };

    home.packages = with pkgs; [
      slurp
    ];

    home.file.".config/mango/config.d" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/mango/config.d";
      recursive = true;
    };

    home.file.".config/mango/dms" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/mango/dms";
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
