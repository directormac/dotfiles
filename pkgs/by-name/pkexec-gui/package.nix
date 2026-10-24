{
  bash,
  coreutils,
  stdenv,
  xhost,
}:

stdenv.mkDerivation (_finalAttrs: {
  dontUnpack = true;

  installPhase = ''
        mkdir -p $out/bin $out/share/polkit-1/actions

        # 1. Elevated runner executed as root by pkexec
        cat > $out/bin/pkexec-gui-runner << 'EOF'
    #!${bash}/bin/bash
    set -euo pipefail

    WAYLAND_SOCKET="''${1:-}"
    DISPLAY_VAL="''${2:-}"
    XAUTH_VAL="''${3:-}"
    XCUR_THEME="''${4:-catppuccin-mocha-mauve-cursors}"
    XCUR_SIZE="''${5:-24}"
    GTK_THM="''${6:-catppuccin-mocha-mauve-standard:dark}"
    shift 6

    # Ensure root runtime directory exists with strict permissions
    ${coreutils}/bin/mkdir -p -m 0700 /run/user/0 2>/dev/null || true
    export XDG_RUNTIME_DIR="/run/user/0"

    # Propagate system themes, icons, and configuration paths
    export XDG_DATA_DIRS="/run/current-system/sw/share:''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
    export XDG_CONFIG_DIRS="/etc/xdg:''${XDG_CONFIG_DIRS:-/etc/xdg}"

    export DISPLAY="''${DISPLAY_VAL:-}"
    export XAUTHORITY="''${XAUTH_VAL:-}"
    if [ -n "''${WAYLAND_SOCKET:-}" ]; then
      export WAYLAND_DISPLAY="''${WAYLAND_SOCKET}"
    fi

    export GTK_THEME="''${GTK_THM}"
    export XCURSOR_THEME="''${XCUR_THEME}"
    export XCURSOR_SIZE="''${XCUR_SIZE}"

    # Ensure root has GTK3/4 settings file matching system dark configuration
    ${coreutils}/bin/mkdir -p /root/.config/gtk-3.0 /root/.config/gtk-4.0 2>/dev/null || true
    if [ -f /etc/xdg/gtk-3.0/settings.ini ]; then
      ${coreutils}/bin/cp -f /etc/xdg/gtk-3.0/settings.ini /root/.config/gtk-3.0/settings.ini 2>/dev/null || true
    fi
    if [ -f /etc/xdg/gtk-4.0/settings.ini ]; then
      ${coreutils}/bin/cp -f /etc/xdg/gtk-4.0/settings.ini /root/.config/gtk-4.0/settings.ini 2>/dev/null || true
    fi
    exec "$@"
    EOF
        chmod +x $out/bin/pkexec-gui-runner

        # 2. Client wrapper executed by user
        cat > $out/bin/pkexec-gui << EOF
    #!${bash}/bin/bash
    set -euo pipefail

    if [ "\$#" -eq 0 ]; then
      echo "Usage: pkexec-gui <command> [args...]" >&2
      exit 1
    fi

    # Authorize root on X11 / Xwayland if DISPLAY is set
    if [ -n "\''${DISPLAY:-}" ]; then
      ${xhost}/bin/xhost +si:localuser:root >/dev/null 2>&1 || true
    fi

    # Resolve absolute Wayland socket path
    WAYLAND_SOCKET=""
    if [ -n "\''${WAYLAND_DISPLAY:-}" ]; then
      if [[ "\$WAYLAND_DISPLAY" = /* ]]; then
        WAYLAND_SOCKET="\$WAYLAND_DISPLAY"
      elif [ -n "\''${XDG_RUNTIME_DIR:-}" ]; then
        WAYLAND_SOCKET="\$XDG_RUNTIME_DIR/\$WAYLAND_DISPLAY"
      else
        WAYLAND_SOCKET="/run/user/\$(${coreutils}/bin/id -u)/\$WAYLAND_DISPLAY"
      fi
    fi

    XAUTH="\''${XAUTHORITY:-\$HOME/.Xauthority}"
    XCUR_THEME="\''${XCURSOR_THEME:-catppuccin-mocha-mauve-cursors}"
    XCUR_SIZE="\''${XCURSOR_SIZE:-24}"
    GTK_THM="\''${GTK_THEME:-catppuccin-mocha-mauve-standard:dark}"

    RUNNER="$out/bin/pkexec-gui-runner"
    if [ ! -x "\$RUNNER" ]; then
      RUNNER="\$(command -v pkexec-gui-runner || echo "/run/current-system/sw/bin/pkexec-gui-runner")"
    fi

    # Execute via pkexec wrapper (or fallback to PATH pkexec)
    PKEXEC_BIN="/run/wrappers/bin/pkexec"
    if [ ! -x "\$PKEXEC_BIN" ]; then
      PKEXEC_BIN="pkexec"
    fi

    exec "\$PKEXEC_BIN" "\$RUNNER" "\$WAYLAND_SOCKET" "\''${DISPLAY:-}" "\$XAUTH" "\$XCUR_THEME" "\$XCUR_SIZE" "\$GTK_THM" "\$@"
    EOF
        chmod +x $out/bin/pkexec-gui

        # 3. sudo-gui wrapper for terminal usage
        cat > $out/bin/sudo-gui << EOF
    #!${bash}/bin/bash
    set -euo pipefail

    if [ "\$#" -eq 0 ]; then
      echo "Usage: sudo-gui <command> [args...]" >&2
      exit 1
    fi

    if [ -n "\''${DISPLAY:-}" ]; then
      ${xhost}/bin/xhost +si:localuser:root >/dev/null 2>&1 || true
    fi

    WAYLAND_SOCKET=""
    if [ -n "\''${WAYLAND_DISPLAY:-}" ]; then
      if [[ "\$WAYLAND_DISPLAY" = /* ]]; then
        WAYLAND_SOCKET="\$WAYLAND_DISPLAY"
      elif [ -n "\''${XDG_RUNTIME_DIR:-}" ]; then
        WAYLAND_SOCKET="\$XDG_RUNTIME_DIR/\$WAYLAND_DISPLAY"
      else
        WAYLAND_SOCKET="/run/user/\$(${coreutils}/bin/id -u)/\$WAYLAND_DISPLAY"
      fi
    fi

    XAUTH="\''${XAUTHORITY:-\$HOME/.Xauthority}"
    XCUR_THEME="\''${XCURSOR_THEME:-catppuccin-mocha-mauve-cursors}"
    XCUR_SIZE="\''${XCURSOR_SIZE:-24}"
    GTK_THM="\''${GTK_THEME:-catppuccin-mocha-mauve-standard:dark}"

    RUNNER="$out/bin/pkexec-gui-runner"
    if [ ! -x "\$RUNNER" ]; then
      RUNNER="\$(command -v pkexec-gui-runner || echo "/run/current-system/sw/bin/pkexec-gui-runner")"
    fi

    exec sudo -EH "\$RUNNER" "\$WAYLAND_SOCKET" "\''${DISPLAY:-}" "\$XAUTH" "\$XCUR_THEME" "\$XCUR_SIZE" "\$GTK_THM" "\$@"
        chmod +x $out/bin/sudo-gui
        ln -s pkexec-gui $out/bin/gui-exec

        # 4. Polkit action policy file
        cat > $out/share/polkit-1/actions/org.dotfiles.pkexec-gui.policy << EOF
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE policyconfig PUBLIC
     "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
     "http://www.freedesktop.org/standards/PolicyKit/1/policyconfig.dtd">
    <policyconfig>
      <vendor>Dotfiles Desktop</vendor>
      <vendor_url>https://github.com/artifex</vendor_url>
      <icon_name>dialog-password</icon_name>

      <action id="org.dotfiles.pkexec-gui">
        <description>Run graphical application with administrator privileges</description>
        <message>Authentication is required to run a graphical application as administrator</message>
        <defaults>
          <allow_any>auth_admin</allow_any>
          <allow_inactive>auth_admin</allow_inactive>
          <allow_active>auth_admin</allow_active>
        </defaults>
        <annotate key="org.freedesktop.policykit.exec.path">$out/bin/pkexec-gui-runner</annotate>
        <annotate key="org.freedesktop.policykit.exec.allow_gui">true</annotate>
      </action>
    </policyconfig>
    EOF
  '';

  pname = "pkexec-gui";
  version = "1.0.0";

  meta = {
    description = "Seamless Wayland/X11 GUI application elevation wrapper using Polkit";
    mainProgram = "pkexec-gui";
  };
})
