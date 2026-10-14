{
  perSystem =
    {
      pkgs,
      config,
      self',
      ...
    }:
    {
      devshells.default = {
        devshell.motd = ''
          {bold}{202}🔨 Welcome to devshell, ''$USER!{reset}
          $(type -p menu &>/dev/null && menu)
        '';

        packages = [
          pkgs.python3
          config.agenix-rekey.package
          config.treefmt.build.wrapper
          self'.packages.tmux
          self'.packages.nh

          self'.packages.nvim-dev
          self'.packages.yazi-dev
          self'.packages.wl-kbptr-dev

          pkgs.rage
          pkgs.television
          pkgs.nix-search-tv
          pkgs.jq

          # Nightly neovim that loads the live repo config (hot reload)
        ];

        commands = [
          {
            name = "age";
            command = "rage \"$@\"";
            help = "alias for rage";
          }
          {
            name = "v";
            category = "neovim";
            command = "NVIM_PROFILER=1 nvim \"$@\"";
            help = "Neovim with live configuration reload from repository";
          }
          {
            name = "update-nvim";
            category = "neovim";
            help = "Check and update Neovim dependencies (Neovim nightly overlay, Blink inputs, and GitHub plugins)";
            command = ''
              repo_root="$(git rev-parse --show-toplevel)"
              bash "$repo_root/nixos/scripts/update-neovim.sh" "$@"
            '';
          }
          {
            name = "flake-update";
            category = "flake";
            help = "Update specific flake inputs (e.g. 'flake-update blink-cmp' or 'flake-update --all')";
            command = ''
              repo_root="$(git rev-parse --show-toplevel)"
              flake_dir="$repo_root/nixos"

              if [ "$#" -eq 0 ]; then
                echo "Usage: flake-update <input1> [input2 ...]"
                echo "       flake-update --all"
                echo "       flake-update --list"
                echo ""
                echo "Tip: Run 'update-nvim' to check and update Neovim inputs and plugins."
                exit 1
              fi

              case "$1" in
                --list)
                  echo "Root inputs in $flake_dir/flake.nix:"
                  nix flake metadata "$flake_dir" --json 2>/dev/null | jq -r '.locks.nodes.root.inputs | keys[]'
                  ;;
                --all)
                  echo "Updating all flake inputs in $flake_dir..."
                  nix flake update --flake "$flake_dir"
                  ;;
                *)
                  echo "Updating inputs: $* in $flake_dir..."
                  nix flake update --flake "$flake_dir" "$@"
                  ;;
              esac
            '';
          }
          {
            name = "tmux-reload";
            category = "tmux";
            help = "Quickly reload the active tmux session from tmux.nix without rebuilding";
            command = ''
              repo_root="$(git rev-parse --show-toplevel)"
              eval_expr="((builtins.getFlake \"git+file://$repo_root?dir=nixos\").nixosConfigurations.nixos.config.home-manager.users.artifex.xdg.configFile.\"tmux/tmux.conf\").text"
              conf=$(mktemp /tmp/tmux-conf.XXXXXX)
              echo "Evaluating tmux configuration from flake..."
              if nix eval --impure --raw --expr "$eval_expr" > "$conf" 2>/dev/null; then
                tmux source-file "$conf"
                echo "Tmux reloaded with latest configuration from tmux.nix!"
              else
                echo "Failed to evaluate tmux configuration." >&2
              fi
              rm -f "$conf"
            '';
          }
          {
            name = "tmux-test";
            category = "tmux";
            help = "Run an isolated test tmux session using tmux.nix without rebuilding";
            command = ''
              repo_root="$(git rev-parse --show-toplevel)"
              eval_expr="((builtins.getFlake \"git+file://$repo_root?dir=nixos\").nixosConfigurations.nixos.config.home-manager.users.artifex.xdg.configFile.\"tmux/tmux.conf\").text"
              conf=$(mktemp /tmp/tmux-conf.XXXXXX)
              echo "Evaluating tmux configuration from flake..."
              if nix eval --impure --raw --expr "$eval_expr" > "$conf" 2>/dev/null; then
                echo "Starting isolated test tmux session on socket 'test'..."
                tmux -L test -f "$conf" new-session -A -s test
              else
                echo "Failed to evaluate tmux configuration." >&2
              fi
              rm -f "$conf"
            '';
          }
        ];

        env = [
          # {
          #   name = "YAZI_CONFIG_HOME";
          #   eval = "$([ -d \"$PRJ_ROOT/config/yazi\" ] && echo \"$PRJ_ROOT/config/yazi\" || echo \"$PRJ_ROOT/../config/yazi\")";
          # }
          {
            name = "NVIM_DEV_CONFIG";
            eval = "$([ -d \"$PRJ_ROOT/config/nvim\" ] && echo \"$PRJ_ROOT/config/nvim\" || echo \"$PRJ_ROOT/../config/nvim\")";
          }
          # {
          #   name = "NVIM_PROFILER";
          #   eval = 1;
          # }
        ];
      };
    };
}
