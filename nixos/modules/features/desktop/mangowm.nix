{ inputs, self, ... }: {

  # Reference https://mangowm.github.io/docs/nix-options
  flake.homeModules.mangowm =
    { config, pkgs, ... }:
    {

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

        settings = {
          source_optional = [
            "./config.toml"
          ];
        };

        autostart_sh =
          # sh
          ''
            dms run &
            wl-clip-persist --clipboard both --reconnect-tries 5 &
            wl-paste --watch cliphist store &
            wl-paste --type image --watch cliphist store &
          '';

      };

      home.file.".config/mango/config.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.preferences.dotsConfigPath}/mango/config.toml";
      home.file.".config/mango/bind.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.preferences.dotsConfigPath}/mango/bind.toml";
      home.file.".config/mango/rule.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.preferences.dotsConfigPath}/mango/rule.toml";
      home.file.".config/mango/tag.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.preferences.dotsConfigPath}/mango/tag.toml";

      xdg.configFile."television/cable/mango-clients.toml".text =
        # toml
        ''
          [metadata]
          name = "mango-clients"
          description = "Manage active window manager clients with a detailed preview"

          [source]
          # Line format: ID │ APPID │ TITLE
          command = "mmsg get all-clients | jq -r '.clients[] | \"\\(.id) │ \\(.appid) │ \\(.title)\"'"

          [preview]
          # We use jq to match the current line's window ID back against the full state,
          # and then print out an itemized list of key-value properties.
          command = "WINDOW_ID=$(echo '{}' | cut -d'│' -f1 | tr -d ' '); mmsg get all-clients | jq -r --arg id \"$WINDOW_ID\" '.clients[] | select(.id == $id) | \"🆔 Window ID:   \\(.id)\\n🚀 Application: \\(.appid)\\n📋 Window Title: \\(.title)\\n📌 Workspace:    \\(.workspace // \"N/A\")\\n🔍 Floating:     \\(.is_floating // \"false\")\\n✨ Fullscreen:   \\(.is_fullscreen // \"false\")\"'"

          [keybindings]
          enter = "actions:focus"
          ctrl-y = "actions:copy_info"
          ctrl-x = "actions:kill_client"

          [actions.focus]
          command = "mmsg dispatch focus_window $(echo '{}' | cut -d'│' -f1 | tr -d ' ')"
          mode = "execute"

          [actions.copy_info]
          command = "echo '{}' | cut -d'│' -f2,3 | tr -d ' ' | wl-copy"
          mode = "execute"

          [actions.kill_client]
          command = "mmsg dispatch close_window $(echo '{}' | cut -d'│' -f1 | tr -d ' ')"
          mode = "execute"      '';

      xdg.configFile."xdg-desktop-portal-wlr/config".text =
        # ini
        ''
          [screencast]
          max_fps=60
          chooser_type=simple
          chooser_cmd=${pkgs.slurp}/bin/slurp -f 'Monitor: %o' -or
        '';

      xdg.configFile."xdg-desktop-portal-wlr/mango".text =
        # ini
        ''
          [screencast]
          max_fps=60
          chooser_type=simple
          chooser_cmd=${pkgs.slurp}/bin/slurp -f 'Monitor: %o' -or
        '';

      home.packages = with pkgs; [
        slurp
        wl-clipboard
        libnotify
      ];

      systemd.user.services.mango-session-shutdown = {
        Unit = {
          Description = "Clean up graphical-session targets when Mango WM exits";
          DefaultDependencies = false;
          StopWhenUnneeded = true;
        };
        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStop = "${pkgs.systemd}/bin/systemctl --user --no-block stop graphical-session-pre.target mango-session.target";
        };
        Install = {
          WantedBy = [ "mango-session.target" ];
        };
      };

    };

  flake.nixosModules.mangowm = { config, pkgs, ... }: {
    imports = [
      inputs.mangowm.nixosModules.mango
    ];

    home-manager.users.${config.preferences.user.name} = {
      imports = [
        inputs.mangowm.hmModules.mango
        self.homeModules.mangowm
      ];
    };

    programs.mango.enable = true;

    xdg.portal.wlr = {
      enable = true;
      settings = {
        screencast = {
          max_fps = 60;
          chooser_type = "simple";
          chooser_cmd = "${pkgs.slurp}/bin/slurp -f 'Monitor: %o' -or";
        };
      };
    };

    systemd.user.services.xdg-desktop-portal-wlr.path = with pkgs; [
      slurp
    ];

  };
}
