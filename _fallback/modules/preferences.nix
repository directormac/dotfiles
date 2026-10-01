{ self, ... }:
let
  preferencesSubmodule =
    { lib, ... }:
    {
      options.preferences = {
        user = {
          name = lib.mkOption {
            type = lib.types.str;
            default = "artifex";
            description = "Primary user account name.";
          };

          email = lib.mkOption {
            type = lib.types.str;
            default = "markasena@gmail.com";
            description = "Primary user email address.";
          };
        };

        defaultSession = lib.mkOption {
          type = lib.types.str;
          default = "hyprland-uwsm";
          description = "Default Wayland compositor session for display manager.";
        };

        autostart = lib.mkOption {
          type = lib.types.listOf (
            lib.types.either lib.types.str (lib.types.either lib.types.package lib.types.attrs)
          );
          default = [ ];
          description = "Applications or commands to autostart upon session entry. Can be extended from any flake module.";
          example = [
            "wl-paste --watch cliphist store"
          ];
        };

        persistence = {
          enable = lib.mkEnableOption "enable persistence (for impermanence)";
          nukeRoot.enable = lib.mkEnableOption "Destroy /root on every boot";
          volumeGroup = lib.mkOption {
            type = lib.types.str;
            default = "btrfs_vg";
            description = "Btrfs volume group name";
          };
          user = lib.mkOption {
            type = lib.types.str;
            default = "artifex";
            description = "Main user for persistence paths";
          };
          directories = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Directories to persist";
          };
          files = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Files to persist";
          };
          data.directories = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Data directories to persist";
          };
          data.files = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Data files to persist";
          };
          cache.directories = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Cache directories to persist";
          };
          cache.files = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Cache files to persist";
          };
        };

        # Backwards compatibility alias for previous typo 'options.persistance'
        persistance = lib.mkOption {
          type = lib.types.attrs;
          default = { };
          description = "Deprecated alias for persistence";
        };

        keymap = lib.mkOption {
          type = lib.types.lazyAttrsOf (lib.types.either lib.types.attrs lib.types.package);
          default = { };
          example = {
            "SUPER + d" = {
              "f" = {
                exec = "firefox";
              };
            };
          };
          description = "Global keymap definitions.";
        };
      };
    };
in
{
  flake.nixosModules.preferences =
    { ... }:
    {
      imports = [ preferencesSubmodule ];
    };

  flake.homeModules.preferences =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.preferences;

      toCmd =
        item:
        if lib.isDerivation item then
          lib.getExe item
        else if builtins.isString item then
          item
        else if builtins.isAttrs item && item ? exec then
          item.exec
        else if builtins.isAttrs item && item ? command then
          item.command
        else
          builtins.toString item;

      autostartCmds = map toCmd cfg.autostart;

      autostartScript = pkgs.writeShellScriptBin "session-autostart" ''
        #!/usr/bin/env bash
        set -euo pipefail

        # If invoked directly and systemd graphical-session is running, delegate to systemd service
        if [ -z "''${INVOCATION_ID:-}" ] && systemctl --user is-active graphical-session.target >/dev/null 2>&1; then
          systemctl --user start preferences-autostart.service
          exit 0
        fi

        ${lib.concatMapStringsSep "\n" (cmd: "(${cmd}) & disown") autostartCmds}
      '';
    in
    {
      imports = [ preferencesSubmodule ];

      home.packages = lib.mkIf (autostartCmds != [ ]) [ autostartScript ];

      systemd.user.services.preferences-autostart = lib.mkIf (autostartCmds != [ ]) {
        Unit = {
          Description = "User preferences autostart applications";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${autostartScript}/bin/session-autostart";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };

  # Keep base module referencing preferences for backwards compatibility
  flake.nixosModules.base =
    { ... }:
    {
      imports = [ self.nixosModules.preferences ];
    };
}
