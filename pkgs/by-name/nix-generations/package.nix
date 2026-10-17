{
  coreutils,
  findutils,
  gawk,
  gnused,
  jq,
  nh,
  nix,
  nvd,
  television,
  writeShellApplication,
}:
writeShellApplication {
  excludeShellChecks = [ "SC2012" ];
  name = "nix-generations";

  runtimeInputs = [
    coreutils
    findutils
    gawk
    gnused
    jq
    nh
    nix
    nvd
    television
  ];

  text = ''
    set -euo pipefail

    PROFILE="/nix/var/nix/profiles/system"

    get_current_gen() {
      if [ -e "$PROFILE" ]; then
        readlink "$PROFILE" 2>/dev/null | sed -nE 's/.*system-([0-9]+)-link$/\1/p'
      fi
    }

    cmd_list() {
      curr_num="$(get_current_gen)"

      find /nix/var/nix/profiles -maxdepth 1 -name "system-*-link" 2>/dev/null \
        | sort -V -r \
        | while read -r link; do
            num="$(echo "$link" | sed -nE 's/.*system-([0-9]+)-link$/\1/p')"
            [ -z "$num" ] && continue

            is_curr=" "
            [ "$num" = "$curr_num" ] && is_curr="*"

            target="$(readlink -f "$link")"
            date_ts="$(stat -c "%Y" "$link" 2>/dev/null || stat -c "%Y" "$target" 2>/dev/null || echo 0)"
            date_fmt="$(date -d "@$date_ts" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "unknown")"

            label=""
            if [ -f "$link/boot.json" ]; then
              label="$(jq -r '.["org.nixos.bootspec.v1"].label // empty' "$link/boot.json" 2>/dev/null || true)"
            fi
            if [ -z "$label" ] && [ -f "$link/nixos-version" ]; then
              label="$(cat "$link/nixos-version" 2>/dev/null || true)"
            fi
            if [ -z "$label" ]; then
              label="$(basename "$target" | sed -E 's/^[a-z0-9]+-nixos-system-[^-]+-//')"
            fi

            printf "%s\t%s\t%s\t%s\t%s\n" "$num" "$is_curr" "$date_fmt" "$label" "$target"
          done
    }

    cmd_preview() {
      gen="$1"
      curr_num="$(get_current_gen)"
      link="/nix/var/nix/profiles/system-''${gen}-link"

      if [ ! -e "$link" ]; then
        echo -e "\033[31mGeneration $gen does not exist in $PROFILE.\033[0m" >&2
        exit 1
      fi

      target="$(readlink -f "$link")"
      date_ts="$(stat -c "%Y" "$link" 2>/dev/null || stat -c "%Y" "$target" 2>/dev/null || echo 0)"
      date_fmt="$(date -d "@$date_ts" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "unknown")"

      label=""
      bootspec_json=""
      if [ -f "$link/boot.json" ]; then
        bootspec_json="$(cat "$link/boot.json" 2>/dev/null || true)"
        label="$(echo "$bootspec_json" | jq -r '.["org.nixos.bootspec.v1"].label // empty' 2>/dev/null || true)"
      fi
      if [ -z "$label" ] && [ -f "$link/nixos-version" ]; then
        label="$(cat "$link/nixos-version" 2>/dev/null || true)"
      fi

      kernel_ver="unknown"
      if [ -f "$link/kernel-modules/lib/modules" ]; then
        kernel_ver="$(ls "$link/kernel-modules/lib/modules" 2>/dev/null | head -n 1 || true)"
      fi
      if [ -z "$kernel_ver" ] || [ "$kernel_ver" = "unknown" ]; then
        if [ -L "$link/kernel" ]; then
          kernel_ver="$(basename "$(readlink -f "$link/kernel")" 2>/dev/null || true)"
        fi
      fi

      is_active="false"
      [ "$gen" = "$curr_num" ] && is_active="true"

      echo -e "╭── Generation: \033[1;36m#$gen\033[0m ──────────────────────────────────────────────"
      if [ "$is_active" = "true" ]; then
        echo -e "│ Status:      \033[1;32m● Active (Current System)\033[0m"
      else
        echo -e "│ Status:      \033[33m○ Historical\033[0m"
      fi
      echo -e "│ Created:     \033[1m$date_fmt\033[0m"
      [ -n "$label" ] && echo -e "│ Label:       \033[32m$label\033[0m"
      echo -e "│ Kernel:      \033[35m$kernel_ver\033[0m"
      echo -e "│ Path:        \033[2m$target\033[0m"

      if [ -n "$bootspec_json" ]; then
        initrd="$(echo "$bootspec_json" | jq -r '.["org.nixos.bootspec.v1"].initrd // empty' 2>/dev/null || true)"
        if [ -n "$initrd" ]; then
          echo -e "│ Initrd:      \033[2m$(basename "$initrd")\033[0m"
        fi
      fi

      # Package diff against current generation if not active
      if [ "$is_active" != "true" ] && [ -e "/nix/var/nix/profiles/system-''${curr_num}-link" ]; then
        curr_target="$(readlink -f "/nix/var/nix/profiles/system-''${curr_num}-link")"
        echo -e "├── Closure Diff (#$curr_num → #$gen) ────────────────────────"
        diff_output="$(nix store diff-closures "$curr_target" "$target" 2>/dev/null || true)"
        if [ -n "$diff_output" ]; then
          echo "$diff_output" | sed -E 's/^/│  /' | head -n 25
          line_count="$(echo "$diff_output" | wc -l)"
          if [ "$line_count" -gt 25 ]; then
            echo -e "│  \033[2m... and $((line_count - 25)) more changes\033[0m"
          fi
        else
          echo -e "│  \033[2m(no closure differences detected)\033[0m"
        fi
      fi

      echo -e "├── Actions ──────────────────────────────────────────────────"
      echo -e "│ • \033[1mEnter\033[0m:   Switch system to this generation (activate)"
      echo -e "│ • \033[1mCtrl-b\033[0m:  Set as boot default (without switching active system)"
      echo -e "│ • \033[1mCtrl-d\033[0m:  Delete this generation"
      echo -e "│ • \033[1mCtrl-o\033[0m:  Delete older generations (keep latest)"
      echo -e "│ • \033[1mCtrl-y\033[0m:  Copy store path to clipboard"
      echo -e "╰─────────────────────────────────────────────────────────────"
    }

    cmd_switch() {
      gen="$1"
      echo -e "\033[34m>\033[0m \033[1mSwitching to generation #$gen...\033[0m"
      sudo nix-env -p "$PROFILE" --switch-generation "$gen"
      echo -e "\033[34m>\033[0m \033[1mActivating generation #$gen...\033[0m"
      sudo "$PROFILE/bin/switch-to-configuration" switch
      echo -e "\033[32m✔\033[0m \033[1mSuccessfully switched to generation #$gen\033[0m"
    }

    cmd_boot() {
      gen="$1"
      echo -e "\033[34m>\033[0m \033[1mSetting generation #$gen as boot default...\033[0m"
      sudo nix-env -p "$PROFILE" --switch-generation "$gen"
      sudo "$PROFILE/bin/switch-to-configuration" boot
      echo -e "\033[32m✔\033[0m \033[1mSuccessfully set generation #$gen as boot default\033[0m"
    }

    cmd_delete() {
      gen="$1"
      curr_num="$(get_current_gen)"
      if [ "$gen" = "$curr_num" ]; then
        echo -e "\033[31mError: Cannot delete currently active generation #$gen!\033[0m" >&2
        exit 1
      fi
      echo -e "\033[33m>\033[0m \033[1mDeleting generation #$gen...\033[0m"
      sudo nix-env -p "$PROFILE" --delete-generations "$gen"
      echo -e "\033[32m✔\033[0m \033[1mDeleted generation #$gen\033[0m"
    }

    cmd_delete_older() {
      target="''${1:-5}"
      # If target is a generation number, delete all older than it; otherwise treat as keep count
      curr_num="$(get_current_gen)"
      echo -e "\033[33m>\033[0m \033[1mRemoving older generations (keeping current #$curr_num)...\033[0m"
      if [[ "$target" =~ ^[0-9]+$ ]] && [ "$target" -gt 50 ]; then
        # Generation number: delete generations with numbers strictly less than target
        find /nix/var/nix/profiles -maxdepth 1 -name "system-*-link" 2>/dev/null \
          | sort -V \
          | while read -r link; do
              num="$(echo "$link" | sed -nE 's/.*system-([0-9]+)-link$/\1/p')"
              if [ -n "$num" ] && [ "$num" -lt "$target" ] && [ "$num" != "$curr_num" ]; then
                echo "  Deleting generation #$num..."
                sudo nix-env -p "$PROFILE" --delete-generations "$num" || true
              fi
            done
      else
        # Keep count (e.g. 3 or 5)
        keep="''${target:-3}"
        echo "  Invoking nh clean to keep latest $keep generations..."
        nh clean all --keep "$keep"
      fi
      echo -e "\033[32m✔\033[0m \033[1mOlder generations cleanup complete.\033[0m"
    }

    subcmd="''${1:-list}"
    case "$subcmd" in
      list)
        cmd_list
        ;;
      preview)
        if [ -z "''${2:-}" ]; then
          echo "Usage: nix-generations preview <generation-number>" >&2
          exit 1
        fi
        cmd_preview "$2"
        ;;
      switch)
        if [ -z "''${2:-}" ]; then
          echo "Usage: nix-generations switch <generation-number>" >&2
          exit 1
        fi
        cmd_switch "$2"
        ;;
      boot)
        if [ -z "''${2:-}" ]; then
          echo "Usage: nix-generations boot <generation-number>" >&2
          exit 1
        fi
        cmd_boot "$2"
        ;;
      delete)
        if [ -z "''${2:-}" ]; then
          echo "Usage: nix-generations delete <generation-number>" >&2
          exit 1
        fi
        cmd_delete "$2"
        ;;
      delete-older)
        cmd_delete_older "''${2:-3}"
        ;;
      tv|channel|menu)
        exec tv nix-generations
        ;;
      -h|--help)
        echo "Usage: nix-generations [list|preview <gen>|switch <gen>|boot <gen>|delete <gen>|delete-older [N]|tv]"
        exit 0
        ;;
      *)
        echo "Unknown command: $subcmd" >&2
        exit 1
        ;;
    esac
  '';

  meta.description = "Inspect, switch, and prune NixOS system generations with Television integration";
}
