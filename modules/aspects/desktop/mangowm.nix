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
        ...
      }:
      let
        tv-mango-client-preview = pkgs.writeShellScript "tv-mango-client-preview" ''
          id="$1"
          mmsg get all-clients 2>/dev/null | ${pkgs.jq}/bin/jq -r --arg id "$id" '
            .clients[] | select((.id|tostring) == $id) |
            "\(.title // "Untitled")\n" +
            "id: \(.id)\n" +
            "app: \(.appid // "N/A")\n" +
            "workspace: \(.workspace // "N/A")\n" +
            "floating: \(.is_floating // false) | fullscreen: \(.is_fullscreen // false)"
          '
        '';

        tv-mango-tags-preview = pkgs.writeShellScript "tv-mango-tags-preview" ''
          tag_idx="$1"
          mmsg get all-tags 2>/dev/null | ${pkgs.jq}/bin/jq -r --arg idx "$tag_idx" '
            .tags[] | select((.index|tostring) == $idx) |
            "tag \(.index) (monitor: \(.monitor))\n" +
            "focused: \(.is_focused // false)\n" +
            "clients: \(.clients | length)"
          '
        '';
      in
      {
        home.file.".config/mango/bind.toml".source = config.lib.dots.link "mango/bind.toml";
        home.file.".config/mango/config.toml".source = config.lib.dots.link "mango/config.toml";
        home.file.".config/mango/rule.toml".source = config.lib.dots.link "mango/rule.toml";
        home.file.".config/mango/tag.toml".source = config.lib.dots.link "mango/tag.toml";

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
            description = "Manage active MangoWM window clients (focus, close, float, fullscreen)"
            requirements = ["mmsg", "jq"]

            [source]
            command = "mmsg get all-clients 2>/dev/null | jq -r '.clients[] | [(.id|tostring), (.appid // \"unknown\"), (.title // \"\")] | @tsv'"
            display = "[{split:\t:0}] {split:\t:1}  │  {split:\t:2}"
            output = "{split:\t:0}"

            [preview]
            command = "${tv-mango-client-preview} '{split:\t:0}'"

            [keybindings]
            enter = "actions:focus"
            ctrl-x = "actions:close_window"
            ctrl-d = "actions:close_window"
            ctrl-f = "actions:toggle_floating"
            ctrl-m = "actions:fullscreen"
            ctrl-y = "actions:copy_info"

            [actions.focus]
            description = "Focus the selected window"
            command = "mmsg dispatch focus_window '{split:\t:0}'"
            mode = "execute"

            [actions.close_window]
            description = "Close the selected window"
            command = "mmsg dispatch close_window '{split:\t:0}'"
            mode = "execute"

            [actions.toggle_floating]
            description = "Toggle floating mode for window"
            command = "mmsg dispatch togglefloating client,'{split:\t:0}'"
            mode = "execute"

            [actions.fullscreen]
            description = "Toggle fullscreen for window"
            command = "mmsg dispatch togglefullscreen client,'{split:\t:0}'"
            mode = "execute"

            [actions.copy_info]
            description = "Copy window info to clipboard"
            command = "echo -n '{split:\t:2}' | wl-copy"
            mode = "execute"
          '';

        xdg.configFile."television/cable/mango-tags.toml".text =
          # toml
          ''
            [metadata]
            name = "mango-tags"
            description = "Fuzzy search and switch MangoWM workspace tags"
            requirements = ["mmsg", "jq"]

            [source]
            command = "mmsg get all-tags 2>/dev/null | jq -r '.tags[] | [.monitor, (.index|tostring), (if .is_focused then \"Focused\" else \"Idle\" end), (.clients|length|tostring)] | @tsv'"
            display = "[{split:\t:0}] Tag {split:\t:1}  │  {split:\t:2}  │  Clients: {split:\t:3}"
            output = "{split:\t:1}"

            [preview]
            command = "${tv-mango-tags-preview} '{split:\t:1}'"

            [keybindings]
            enter = "actions:switch"
            ctrl-y = "actions:copy_tag"

            [actions.switch]
            description = "Switch to this workspace tag"
            command = "mmsg dispatch tag '{split:\t:1}'"
            mode = "execute"

            [actions.copy_tag]
            description = "Copy tag index to clipboard"
            command = "echo -n '{split:\t:1}' | wl-copy"
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
