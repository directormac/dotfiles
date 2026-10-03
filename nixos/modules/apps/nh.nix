{ inputs, self, ... }:
{

  flake.nixosModules.nh =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    {

      programs.nh = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.nh;
        clean = {
          enable = true;
          extraArgs = "--keep-since 2d --keep 2";
        };
        # Leave flake unset so NixOS environment.variables.NH_FLAKE does not hardcode
        # a static path, allowing our dynamic wrapper to resolve branch/worktree dynamically.
        flake = null;
      };

      environment.systemPackages = with pkgs; [
        nix-output-monitor
        nvd
      ];
    };

  perSystem =
    { pkgs, ... }:
    let
      runtimePkgs = with pkgs; [
        nix-output-monitor
        nvd
        git
        tmux
        coreutils
      ];
    in
    {
      packages.nh = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.nh;
        inherit runtimePkgs;
        env = {
          NH_NOM = {
            data = "1";
            esc-fn = toString;
          };
          NH_SEARCH_CHANNEL = {
            data = "unstable";
            esc-fn = toString;
          };
        };
        runShell = [
          ''
            # If NH_FLAKE is empty or set to the default static base path (or legacy _fallback), perform dynamic resolution
            if [ -z "$NH_FLAKE" ] || [ "$NH_FLAKE" = "/home/$USER/.dotfiles/nixos" ] || [ "$NH_FLAKE" = "/home/artifex/.dotfiles/nixos" ] || [ "$NH_FLAKE" = "/home/$USER/.dotfiles/_fallback" ] || [ "$NH_FLAKE" = "/home/artifex/.dotfiles/_fallback" ]; then
              __nh_detect_flake() {
                # 1. Environment variable override
                if [ -n "$NH_WORKTREE" ]; then
                  local cand="/home/$USER/Code/.worktrees/.dotfiles/$NH_WORKTREE/nixos"
                  if [ -f "$cand/flake.nix" ]; then
                    echo "$cand"
                    return 0
                  fi
                fi

                # 2. Check current working directory git root
                local git_root
                git_root="$(git rev-parse --show-toplevel 2>/dev/null)"
                if [ -n "$git_root" ]; then
                  if [ -f "$git_root/nixos/flake.nix" ]; then
                    echo "$git_root/nixos"
                    return 0
                  elif [ -f "$git_root/flake.nix" ]; then
                    echo "$git_root"
                    return 0
                  fi
                fi

                # 3. Check tmux session or pane
                if [ -n "$TMUX" ]; then
                  local pane_path pane_git
                  pane_path="$(tmux display-message -p '#{pane_current_path}' 2>/dev/null)"
                  if [ -n "$pane_path" ]; then
                    pane_git="$(git -C "$pane_path" rev-parse --show-toplevel 2>/dev/null)"
                    if [ -n "$pane_git" ]; then
                      if [ -f "$pane_git/nixos/flake.nix" ]; then
                        echo "$pane_git/nixos"
                        return 0
                      elif [ -f "$pane_git/flake.nix" ]; then
                        echo "$pane_git"
                        return 0
                      fi
                    fi
                  fi

                  local session_name
                  session_name="$(tmux display-message -p '#{session_name}' 2>/dev/null)"
                  if [[ "$session_name" =~ ^dotfiles-(.+) ]]; then
                    local wt_name="''${BASH_REMATCH[1]}"
                    local wt_cand="/home/$USER/Code/.worktrees/.dotfiles/$wt_name/nixos"
                    if [ -f "$wt_cand/flake.nix" ]; then
                      echo "$wt_cand"
                      return 0
                    fi
                  fi
                fi

                # 4. Check git worktrees in ~/.dotfiles for checked out branch
                if [ -d "/home/$USER/.dotfiles" ]; then
                  local cur_branch
                  cur_branch="$(git -C "/home/$USER/.dotfiles" branch --show-current 2>/dev/null)"
                  if [ -n "$cur_branch" ] && [ "$cur_branch" != "main" ] && [ "$cur_branch" != "master" ]; then
                    local branch_slug
                    branch_slug="$(echo "$cur_branch" | tr '/' '-')"
                    local wt_cand="/home/$USER/Code/.worktrees/.dotfiles/$branch_slug/nixos"
                    if [ -f "$wt_cand/flake.nix" ]; then
                      echo "$wt_cand"
                      return 0
                    fi
                  fi
                fi

                # 5. Fallback to main dotfiles flake
                echo "/home/$USER/.dotfiles/nixos"
              }

              __detected="$(__nh_detect_flake)"
              if [ -n "$__detected" ]; then
                export NH_FLAKE="$__detected"
                if [[ "$__detected" == *"/Code/.worktrees/.dotfiles/"* ]]; then
                  __wt_display="''${__detected#*/Code/.worktrees/.dotfiles/}"
                  __wt_display="''${__wt_display%/nixos}"
                  echo -e "\033[34m>\033[0m \033[1m[nh]\033[0m Detected worktree branch: \033[32m$__wt_display\033[0m ($__detected)" >&2
                fi
              fi
            fi
          ''
        ];
      };
    };

}
