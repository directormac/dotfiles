# Core NH Wrapper Aspect: Dynamic git worktree detection for nh
{
  lib,
  den,
  self,
  ...
}:
{
  den.aspects.core.nh = {
    nixos =
      {
        config,
        pkgs,
        ...
      }:
      {
        environment.systemPackages = with pkgs; [
          nix-output-monitor
          nvd
        ];

        imports = lib.optional (self ? wrappers && self.wrappers ? nh) self.wrappers.nh.install;

        programs.nh = {
          enable = true;

          clean = {
            enable = lib.mkDefault true;
            extraArgs = lib.mkDefault "--keep-since 4d --keep 3";
          };

          flake = lib.mkDefault (
            let
              primaryUser = lib.findFirst (u: u.isNormalUser) null (builtins.attrValues config.users.users);
            in
            if primaryUser != null then "${primaryUser.home}/.dotfiles" else "/home/artifex/.dotfiles"
          );

          package = if config ? wrappers && config.wrappers ? nh then config.wrappers.nh.wrapper else pkgs.nh;
        };
      };
  };

  flake.wrappers.nh =
    {
      config,
      lib,
      pkgs,
      wlib,
      ...
    }:
    {
      imports = [ wlib.modules.default ];

      options.dotfilesPath = lib.mkOption {
        default = "$HOME/.dotfiles";
        description = "Main dotfiles checkout; fallback flake root.";
        type = lib.types.str;
      };

      options.worktreesPath = lib.mkOption {
        default = "$HOME/Code/.worktrees/.dotfiles";
        description = "Directory holding the dotfiles git worktrees, one per branch.";
        type = lib.types.str;
      };

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

      config.package = pkgs.nh;

      config.runShell = [
        ''
          # Trigger dynamic detection if NH_FLAKE is empty, invalid, or points to the base flake
          if [ -z "$NH_FLAKE" ] || [ ! -f "$NH_FLAKE/flake.nix" ] || [ "$NH_FLAKE" = "${config.dotfilesPath}" ]; then
            __nh_target=""

            # 1. Environment variable override
            if [ -n "$NH_WORKTREE" ] && [ -f "${config.worktreesPath}/$NH_WORKTREE/flake.nix" ]; then
              __nh_target="${config.worktreesPath}/$NH_WORKTREE"
            fi

            # 2. Check current working directory or git worktree root
            if [ -z "$__nh_target" ]; then
              __git_root="$(git rev-parse --show-toplevel 2>/dev/null)"
              if [ -n "$__git_root" ] && [ -f "$__git_root/flake.nix" ]; then
                __nh_target="$__git_root"
              fi
            fi

            # 3. Check tmux session name (e.g. dotfiles-<worktree>)
            if [ -z "$__nh_target" ] && [ -n "$TMUX" ]; then
              __session_name="$(tmux display-message -p '#{session_name}' 2>/dev/null)"
              if [[ "$__session_name" =~ ^dotfiles-(.+) ]]; then
                __wt_cand="${config.worktreesPath}/''${BASH_REMATCH[1]}"
                [ -f "$__wt_cand/flake.nix" ] && __nh_target="$__wt_cand"
              fi
            fi

            export NH_FLAKE="''${__nh_target:-${config.dotfilesPath}}"
            export DOTFILES_ROOT="''${DOTFILES_ROOT:-$NH_FLAKE}"

            if [[ "$NH_FLAKE" == "${config.worktreesPath}/"* ]]; then
              __wt_display="''${NH_FLAKE#${config.worktreesPath}/}"
              echo -e "\033[34m>\033[0m \033[1m[nh]\033[0m Detected worktree branch: \033[32m$__wt_display\033[0m ($NH_FLAKE)" >&2
            fi
          fi
        ''
      ];

      config.runtimePkgs = with pkgs; [
        nix-output-monitor
        nvd
        git
        tmux
        coreutils
      ];
    };

  # Exposes flake apps under the name of each host / home for building with nh.
  perSystem =
    { pkgs, ... }:
    {
      packages = den.lib.nh.denPackages { fromFlake = true; } pkgs;
    };
}
