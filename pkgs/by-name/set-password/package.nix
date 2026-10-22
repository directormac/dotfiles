{
  age,
  coreutils,
  git,
  python3,
  whois,
  writeShellApplication,
}:
let
  pythonWithDbus = python3.withPackages (ps: [ ps.dbus-python ]);
in
writeShellApplication {
  name = "set-password";

  runtimeInputs = [
    age
    coreutils
    git
    pythonWithDbus
    whois
  ];

  text = ''
        target="''${1:-artifex}"
        case "$target" in
          artifex)
            secret_rel=".secrets/users/artifex/password.age"
            secret_name="password-artifex"
            label="artifex (and root fallback)"
            ;;
          root)
            secret_rel=".secrets/users/artifex/root-password.age"
            secret_name="password-root"
            label="root"
            ;;
          *)
            echo "Usage: set-password [artifex|root]" >&2
            exit 1
            ;;
        esac

        repo="''${DOTFILES_ROOT:-''${NH_FLAKE:-}}"
        if [[ -z "$repo" ]] || [[ ! -d "$repo/.secrets" ]]; then
          if git_root="$(git rev-parse --show-toplevel 2>/dev/null)" && [[ -d "$git_root/.secrets" ]]; then
            repo="$git_root"
          else
            repo="$HOME/.dotfiles"
          fi
        fi

        if [[ ! -f "$repo/.secrets/master.pub" ]]; then
          echo "error: could not find $repo/.secrets/master.pub" >&2
          exit 1
        fi

        printf "New password for %s: " "$label" >/dev/tty
        IFS= read -r -s pw1 </dev/tty
        printf "\n" >/dev/tty

        if [[ -z "$pw1" ]]; then
          echo "error: password cannot be empty." >&2
          exit 1
        fi

        printf "Confirm new password for %s: " "$label" >/dev/tty
        IFS= read -r -s pw2 </dev/tty
        printf "\n" >/dev/tty

        if [[ "$pw1" != "$pw2" ]]; then
          echo "error: passwords do not match." >&2
          exit 1
        fi

        pw_hash="$(printf '%s\n' "$pw1" | mkpasswd -m yescrypt -s)"
        secret_file="$repo/$secret_rel"
        mkdir -p "$(dirname "$secret_file")"

        printf '%s\n' "$pw_hash" | age -R "$repo/.secrets/master.pub" -o "$secret_file"
        echo "Encrypted master secret: $secret_rel"

        for pub_file in "$repo"/.secrets/hosts/*.pub; do
          [[ -f "$pub_file" ]] || continue
          if ! grep -q '^ssh-' "$pub_file"; then
            continue
          fi
          host_name="$(basename "$pub_file" .pub)"
          pubkey_hash="$(sha256sum "$pub_file" | cut -d' ' -f1)"
          file_hash="$(sha256sum "$secret_file" | cut -d' ' -f1)"
          ident_hash="$(printf '%s%s' "$pubkey_hash" "$file_hash" | sha256sum | cut -c1-32)"

          rekey_dir="$repo/.secrets/rekeyed/$host_name"
          mkdir -p "$rekey_dir"
          rm -f "$rekey_dir"/*-"$secret_name.age"
          rekey_out="$rekey_dir/''${ident_hash}-''${secret_name}.age"
          printf '%s\n' "$pw_hash" | age -R "$pub_file" -o "$rekey_out"
          echo "Rekeyed for host '$host_name': .secrets/rekeyed/$host_name/''${ident_hash}-''${secret_name}.age"
        done

        git -C "$repo" add "$secret_file" "$repo/.secrets/rekeyed"

        if [[ "$target" == "artifex" ]] && [[ -n "''${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
          echo "Synchronizing GNOME login keyring password..."
          if ! KEYRING_NEW_PW="$pw1" python3 - <<'PY'
    import os
    import sys
    import dbus

    new_pw = os.environ["KEYRING_NEW_PW"]
    bus = dbus.SessionBus()
    svc = bus.get_object("org.freedesktop.secrets", "/org/freedesktop/secrets")
    _, session = svc.OpenSession("plain", dbus.String("", variant_level=1), dbus_interface="org.freedesktop.Secret.Service")
    login_path = dbus.ObjectPath("/org/freedesktop/secrets/collection/login")
    internal_iface = "org.gnome.keyring.InternalUnsupportedGuiltRiddenInterface"

    def make_secret(pw):
        return dbus.Struct((
            dbus.ObjectPath(session),
            dbus.Array([], signature="y"),
            dbus.ByteArray(pw.encode("utf-8")),
            dbus.String("text/plain; charset=utf8"),
        ), signature="oayays")

    def try_unlock(pw):
        svc.Lock([login_path], dbus_interface="org.freedesktop.Secret.Service")
        svc.UnlockWithMasterPassword(login_path, make_secret(pw), dbus_interface=internal_iface)

    try:
        try_unlock(new_pw)
        print("GNOME login keyring already matches the new password and is unlocked.")
        sys.exit(0)
    except Exception:
        pass

    try:
        svc.ChangeWithMasterPassword(login_path, make_secret("12345"), make_secret(new_pw), dbus_interface=internal_iface)
        try_unlock(new_pw)
        print("GNOME login keyring re-encrypted from '12345' to your new password and unlocked.")
        sys.exit(0)
    except Exception:
        sys.exit(1)
    PY
          then
            printf "Current GNOME login keyring password (to re-encrypt login.keyring, or press Enter to skip): " >/dev/tty
            IFS= read -r -s old_kr_pw </dev/tty
            printf "\n" >/dev/tty
            if [[ -n "$old_kr_pw" ]]; then
              KEYRING_OLD_PW="$old_kr_pw" KEYRING_NEW_PW="$pw1" python3 - <<'PY'
    import os
    import dbus

    old_pw = os.environ["KEYRING_OLD_PW"]
    new_pw = os.environ["KEYRING_NEW_PW"]
    bus = dbus.SessionBus()
    svc = bus.get_object("org.freedesktop.secrets", "/org/freedesktop/secrets")
    _, session = svc.OpenSession("plain", dbus.String("", variant_level=1), dbus_interface="org.freedesktop.Secret.Service")
    login_path = dbus.ObjectPath("/org/freedesktop/secrets/collection/login")
    internal_iface = "org.gnome.keyring.InternalUnsupportedGuiltRiddenInterface"

    def make_secret(pw):
        return dbus.Struct((
            dbus.ObjectPath(session),
            dbus.Array([], signature="y"),
            dbus.ByteArray(pw.encode("utf-8")),
            dbus.String("text/plain; charset=utf8"),
        ), signature="oayays")

    svc.ChangeWithMasterPassword(login_path, make_secret(old_pw), make_secret(new_pw), dbus_interface=internal_iface)
    svc.UnlockWithMasterPassword(login_path, make_secret(new_pw), dbus_interface=internal_iface)
    print("GNOME login keyring re-encrypted to your new password and unlocked.")
    PY
            fi
          fi
        fi

        echo "Done! Run 'rebuild-switch' to apply the new password to /etc/shadow."
  '';

  meta.description = "Set declarative agenix password for artifex/root and sync GNOME login keyring";
}
