{
  coreutils,
  git,
  jq,
  nh,
  nix,
  writeShellApplication,
}:
writeShellApplication {
  name = "rebuild-switch";

  runtimeInputs = [
    coreutils
    git
    jq
    nh
    nix
  ];

  text = ''
    set -euo pipefail

    # Determine git repo for current directory or fallback to dotfiles
    GIT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/.dotfiles")"
    export NH_FLAKE="''${NH_FLAKE:-$GIT_ROOT}"
    export NH_OS_FLAKE="''${NH_OS_FLAKE:-$NH_FLAKE}"
    export DOTFILES_ROOT="''${DOTFILES_ROOT:-$NH_FLAKE}"


    # Extract branch, sanitized for NixOS label characters: letters, numbers, ':', '_', '.', '-'
    BRANCH="$(git -C "$GIT_ROOT" branch --show-current 2>/dev/null | tr '/ ' '-_' || echo "")"
    if [ -z "$BRANCH" ]; then
      BRANCH="$(git -C "$GIT_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null | tr '/ ' '-_' || echo "nixos")"
    fi
    [ "$BRANCH" = "HEAD" ] && BRANCH="detached"

    # Extract scope if latest commit uses Conventional Commits (e.g. feat(scope): msg -> scope)
    LAST_COMMIT_MSG="$(git -C "$GIT_ROOT" log -1 --pretty=%s 2>/dev/null || echo "")"
    SCOPE="$(echo "$LAST_COMMIT_MSG" | sed -nE 's/^[a-zA-Z0-9_-]+\(([^)]+)\):.*/\1/p' | tr '/ ' '-_' || echo "")"

    # Extract short revision (7 chars as in lazygit) + dirty state
    REV="$(git -C "$GIT_ROOT" rev-parse --short=7 HEAD 2>/dev/null || echo "unknown")"
    if [ -n "$(git -C "$GIT_ROOT" status --porcelain 2>/dev/null)" ]; then
      REV="''${REV}-dirty"
    fi

    # Human-readable timestamp with minutes (e.g. 2026-10-18-1430)
    TIMESTAMP="$(date +'%Y-%m-%d-%H%M')"

    # Format label: <branch>-<scope if any>-<rev>-<human readable timestamp with minutes>
    if [ -n "$SCOPE" ]; then
      LABEL="''${BRANCH}-''${SCOPE}-''${REV}-''${TIMESTAMP}"
    else
      LABEL="''${BRANCH}-''${REV}-''${TIMESTAMP}"
    fi

    # Sanitize label to allowed NixOS characters only
    LABEL="$(echo "$LABEL" | sed -E 's/[^a-zA-Z0-9:._-]+/-/g')"

    PROFILE="/nix/var/nix/profiles/system"
    PREV_GEN=""
    if [ -e "$PROFILE" ]; then
      PREV_LINK="$(readlink "$PROFILE" 2>/dev/null || true)"
      PREV_GEN="$(echo "$PREV_LINK" | sed -nE 's/.*system-([0-9]+)-link$/\1/p')"
    fi

    echo -e "\033[34m>\033[0m \033[1m[rebuild-switch]\033[0m Target generation label: \033[32m$LABEL\033[0m"
    if [ -n "$PREV_GEN" ]; then
      echo -e "\033[34m>\033[0m \033[1m[rebuild-switch]\033[0m Current active generation: \033[33m$PREV_GEN\033[0m"
    fi

    export NIXOS_LABEL="$LABEL"
    export NIXOS_LABEL_VERSION="$LABEL"

    # Run nh os switch with --impure to ensure NIXOS_LABEL evaluates
    SWITCH_FAILED=0
    nh os switch --impure "$@" || SWITCH_FAILED=$?

    if [ "$SWITCH_FAILED" -ne 0 ]; then
      echo -e "\033[31m!!\033[0m \033[1m[rebuild-switch]\033[0m Rebuild switch failed with exit code $SWITCH_FAILED!" >&2

      # Check if a new generation was created despite the switch/activation failure
      if [ -e "$PROFILE" ] && [ -n "$PREV_GEN" ]; then
        CURR_LINK="$(readlink "$PROFILE" 2>/dev/null || true)"
        CURR_GEN="$(echo "$CURR_LINK" | sed -nE 's/.*system-([0-9]+)-link$/\1/p')"

        if [ -n "$CURR_GEN" ] && [ "$CURR_GEN" -gt "$PREV_GEN" ]; then
          echo -e "\033[33m>\033[0m \033[1m[rebuild-switch]\033[0m Reverting profile from failed generation \033[31m$CURR_GEN\033[0m back to \033[32m$PREV_GEN\033[0m..." >&2
          sudo nix-env -p "$PROFILE" --switch-generation "$PREV_GEN" || true

          echo -e "\033[33m>\033[0m \033[1m[rebuild-switch]\033[0m Deleting failed generation \033[31m$CURR_GEN\033[0m so it does not persist..." >&2
          sudo nix-env -p "$PROFILE" --delete-generations "$CURR_GEN" || true

          echo -e "\033[33m>\033[0m \033[1m[rebuild-switch]\033[0m Reinstalling bootloader for generation \033[32m$PREV_GEN\033[0m..." >&2
          sudo "$PROFILE/bin/switch-to-configuration" boot 2>/dev/null || true

          echo -e "\033[32m✔\033[0m \033[1m[rebuild-switch]\033[0m Failed generation was completely removed and profile rolled back." >&2
        fi
      fi
      exit "$SWITCH_FAILED"
    fi

    echo -e "\033[32m✔\033[0m \033[1m[rebuild-switch]\033[0m Successfully built, activated, and persisted generation: \033[1m$LABEL\033[0m"
  '';

  meta.description = "Rebuild and switch NixOS with lazygit-style generation labels and transient failure rollback";
}
