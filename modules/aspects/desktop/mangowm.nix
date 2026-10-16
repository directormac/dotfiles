# MangoWM Dynamic Tiling Wayland Compositor Leaf Aspect
{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    mangowm = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:mangowm/mango";
    };
  };

  den.aspects.desktop.mangowm = {
    nixos =
      { pkgs, ... }:
      {
        imports = lib.optionals (inputs ? mangowm) [
          inputs.mangowm.nixosModules.mango
        ];

        programs.mango.enable = lib.mkIf (inputs ? mangowm) true;

        systemd.user.services.xdg-desktop-portal-wlr.path = with pkgs; [
          slurp
        ];

        xdg.portal.wlr = {
          settings = {
            screencast = {
              chooser_cmd = "${pkgs.slurp}/bin/slurp -f 'Monitor: %o' -or";
              chooser_type = "simple";
              max_fps = 60;
            };
          };

          enable = true;
        };
      };

    homeManager =
      {
        config,
        pkgs,
        user,
        ...
      }:
      let
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
      in
      {
        home.file.".config/mango/bind.toml".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/mango/bind.toml";

        home.file.".config/mango/config.toml".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/mango/config.toml";

        home.file.".config/mango/rule.toml".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/mango/rule.toml";

        home.file.".config/mango/tag.toml".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/mango/tag.toml";

        home.packages = with pkgs; [
          slurp
          wl-clipboard
          libnotify
        ];

        imports = lib.optionals (inputs ? mangowm) [
          inputs.mangowm.hmModules.mango
        ];

        systemd.user.services.mango-session-shutdown = {
          Install = {
            WantedBy = [ "mango-session.target" ];
          };

          Service = {
            ExecStop = "${pkgs.systemd}/bin/systemctl --user --no-block stop graphical-session-pre.target mango-session.target";
            RemainAfterExit = true;
            Type = "oneshot";
          };

          Unit = {
            DefaultDependencies = false;
            Description = "Clean up graphical-session targets when Mango WM exits";
            StopWhenUnneeded = true;
          };
        };

        wayland.windowManager.mango = lib.mkIf (inputs ? mangowm) {
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

          enable = true;

          systemd = {
            enable = true;

            extraCommands = [
              "systemctl --user reset-failed"
              "systemctl --user start mango-session.target"
            ];

            variables = [
              "--all"
            ];

            xdgAutostart = true;
          };
        };

        xdg.configFile."television/cable/mango-clients.toml".text =
          # toml
          ''
            [metadata]
            name = "mango-clients"
            description = "Manage active window manager clients with a detailed preview"

            [source]
            command = "mmsg get all-clients | jq -r '.clients[] | \"\\(.id) │ \\(.appid) │ \\(.title)\"'"

            [preview]
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
            mode = "execute"
          '';

        xdg.configFile."xdg-desktop-portal-wlr/mango".text =
          # ini
          ''
            [screencast]
            max_fps=60
            chooser_type=simple
            chooser_cmd=${pkgs.slurp}/bin/slurp -f 'Monitor: %o' -or
          '';
      };

    persistHome.directories = [
      ".local/state/mango"
    ];
  };

}
