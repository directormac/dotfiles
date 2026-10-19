# Tmux Server systemd User Service
#
# Starts the tmux server as a user service, restores the last resurrect
# snapshot once the server is up and snapshots the session on shutdown.
#
# Restore is triggered deterministically in `ExecStartPost` via `tmux run-shell`
# (which populates `$TMUX` so `restore.sh` resolves the server socket) using the
# lock-protected, self-healing wrapper from `tmux.nix`.
{
  lib,
  pkgs,
  resurrectRestoreScript,
  resurrectSaveScript,
  tmuxPkg,
  ...
}:
{
  systemd.user.services.tmux-server = {
    Install.WantedBy = [ "graphical-session.target" ];

    Service = {
      Environment = [ "TMUX_TMPDIR=%t" ];

      ExecStart = lib.mkDefault "${pkgs.writeShellScript "tmux-server" ''
        if [ -z "''${WAYLAND_DISPLAY:-}" ]; then
          i=0
          while [ $i -lt 20 ]; do
            sock=$(ls -t "''${XDG_RUNTIME_DIR:-/tmp}"/wayland-* 2>/dev/null | head -1)
            if [ -n "$sock" ]; then
              export WAYLAND_DISPLAY="''${sock##*/}"
              break
            fi
            i=$((i + 1))
            sleep 0.5
          done
        fi
        if [ -z "''${DISPLAY:-}" ]; then
          sock=$(ls -t /tmp/.X11-unix/X* 2>/dev/null | head -1)
          [ -n "$sock" ] && export DISPLAY=":''${sock##*X}"
        fi
        exec ${tmuxPkg}/bin/tmux start-server
      ''}";

      # `tmux start-server` returns once the server forked, but the server
      # reads `tmux.conf` afterwards. `@continuum-restore` is the last option
      # `tmux.conf` sets, so once it is readable the plugins are loaded and
      # resurrect's `@resurrect-dir` is in place.
      ExecStartPost = "${pkgs.writeShellScript "tmux-restore" ''
        i=0
        while [ $i -lt 100 ]; do
          [ -n "$(${tmuxPkg}/bin/tmux show-option -gqv @continuum-restore 2>/dev/null)" ] && break
          i=$((i + 1))
          sleep 0.1
        done
        ${tmuxPkg}/bin/tmux run-shell "${resurrectRestoreScript}" 2>/dev/null || true
      ''}";

      ExecStop = "${pkgs.writeShellScript "tmux-stop" ''
        ${tmuxPkg}/bin/tmux run-shell "${resurrectSaveScript} quiet" 2>/dev/null || true
      ''}";

      KillMode = lib.mkDefault "mixed";
      RemainAfterExit = lib.mkDefault true;
      Restart = lib.mkDefault "on-failure";
      Type = lib.mkDefault "forking";
    };

    Unit = {
      After = [ "graphical-session.target" ];
      Description = "tmux server (resurrect auto-restore)";
      Documentation = "man:tmux(1)";
      X-RestartIfChanged = false;
      X-StopIfChanged = false;
    };
  };
}
