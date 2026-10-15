# MangoWM Dynamic Tiling Wayland Compositor Leaf Aspect
{
  core,
  den,
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs = {
    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
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
        imports = lib.optionals (inputs ? mangowm) [
          inputs.mangowm.hmModules.mango
        ];

        wayland.windowManager.mango = lib.mkIf (inputs ? mangowm) {
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
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/mango/config.toml";
        home.file.".config/mango/bind.toml".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/mango/bind.toml";
        home.file.".config/mango/rule.toml".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/mango/rule.toml";
        home.file.".config/mango/tag.toml".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/mango/tag.toml";

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

    persistHome.directories = [
      ".local/state/mango"
    ];
  };

}
