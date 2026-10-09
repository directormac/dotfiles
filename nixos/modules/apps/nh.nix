{ self, ... }:
{
  # Declared once here; the flake-parts wrappers module turns this into
  # outputs.wrappers.nh and packages.<system>.nh.
  flake.wrappers.nh =
    {
      config,
      wlib,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ wlib.modules.default ];

      # Shell expressions (expanded at runtime), not Nix paths.
      options.dotfilesPath = lib.mkOption {
        type = lib.types.str;
        default = "$HOME/.dotfiles";
        description = "Main dotfiles checkout; its `nixos/` dir is the fallback flake. Hosts override it from preferences.dotsConfigPath.";
      };

      options.worktreesPath = lib.mkOption {
        type = lib.types.str;
        default = "$HOME/Code/.worktrees/.dotfiles";
        description = "Directory holding the dotfiles git worktrees, one per branch.";
      };

      config.package = pkgs.nh;
      config.runtimePkgs = with pkgs; [
        nix-output-monitor
        nvd
        git
        tmux
        coreutils
      ];
      config.env = {
        NH_NOM = {
          data = "1";
          esc-fn = toString;
        };
        NH_SEARCH_CHANNEL = {
          data = "unstable";
          esc-fn = toString;
        };
      };
      config.runShell = [
        ''
          # Trigger dynamic detection if NH_FLAKE is empty, invalid, or points to the base flake
          if [ -z "$NH_FLAKE" ] || [ ! -f "$NH_FLAKE/flake.nix" ] || [ "$NH_FLAKE" = "${config.dotfilesPath}/nixos" ]; then
            __nh_target=""

            # 1. Environment variable override
            if [ -n "$NH_WORKTREE" ] && [ -f "${config.worktreesPath}/$NH_WORKTREE/nixos/flake.nix" ]; then
              __nh_target="${config.worktreesPath}/$NH_WORKTREE/nixos"
            fi

            # 2. Check current working directory or git worktree root
            if [ -z "$__nh_target" ]; then
              __git_root="$(git rev-parse --show-toplevel 2>/dev/null)"
              if [ -n "$__git_root" ]; then
                if [ -f "$__git_root/nixos/flake.nix" ]; then
                  __nh_target="$__git_root/nixos"
                elif [ -f "$__git_root/flake.nix" ]; then
                  __nh_target="$__git_root"
                fi
              fi
            fi

            # 3. Check tmux session name (e.g. dotfiles-<worktree>)
            if [ -z "$__nh_target" ] && [ -n "$TMUX" ]; then
              __session_name="$(tmux display-message -p '#{session_name}' 2>/dev/null)"
              if [[ "$__session_name" =~ ^dotfiles-(.+) ]]; then
                __wt_cand="${config.worktreesPath}/''${BASH_REMATCH[1]}/nixos"
                [ -f "$__wt_cand/flake.nix" ] && __nh_target="$__wt_cand"
              fi
            fi

            export NH_FLAKE="''${__nh_target:-${config.dotfilesPath}/nixos}"

            if [[ "$NH_FLAKE" == "${config.worktreesPath}/"* ]]; then
              __wt_display="''${NH_FLAKE#${config.worktreesPath}/}"
              __wt_display="''${__wt_display%/nixos}"
              echo -e "\033[34m>\033[0m \033[1m[nh]\033[0m Detected worktree branch: \033[32m$__wt_display\033[0m ($NH_FLAKE)" >&2
            fi
          fi
        ''
      ];
    };

  flake.nixosModules.nh =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ self.wrappers.nh.install ];

      # dotsConfigPath is <checkout>/config, so its parent is the dotfiles checkout.
      wrappers.nh.dotfilesPath = dirOf config.preferences.dotsConfigPath;

      # The wrapper is installed through programs.nh, so wrappers.nh.enable stays off
      # to avoid installing it twice.
      programs.nh = {
        enable = true;
        package = config.wrappers.nh.wrapper;
        # clean = {
        #   enable = true;
        #   extraArgs = "--keep-since 2d --keep 2";
        # };
        # Leave flake unset so NixOS environment.variables.NH_FLAKE does not hardcode
        # a static path, allowing our dynamic wrapper to resolve branch/worktree dynamically.
        flake = null;
      };

      environment.systemPackages = with pkgs; [
        nix-output-monitor
        nvd
      ];
    };
}
