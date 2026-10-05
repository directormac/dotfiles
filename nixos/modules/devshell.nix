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
        packages = [
          config.agenix-rekey.package
          pkgs.rage
          self'.packages.yazi
          self'.packages.nh
          self'.packages.tmux
          pkgs.television
          pkgs.nix-search-tv
          config.treefmt.build.wrapper
        ];

        commands = [
          {
            name = "age";
            command = "rage \"$@\"";
            help = "alias for rage";
          }
          {
            name = "zsh-test";
            category = "shell";
            help = "Run an isolated test zsh shell using shell.nix without rebuilding";
            command = ''
              repo_root="$(git rev-parse --show-toplevel)"
              eval_expr="((builtins.getFlake \"git+file://$repo_root?dir=nixos\").nixosConfigurations.nixos.config.home-manager.users.artifex.programs.zsh.initContent)"
              tmp_zdotdir=$(mktemp -d /tmp/zsh-test.XXXXXX)
              echo "Evaluating zsh configuration from flake..."
              if nix eval --impure --raw --expr "$eval_expr" > "$tmp_zdotdir/.zshrc" 2>/dev/null; then
                echo "Starting isolated test zsh shell with latest configuration..."
                echo "Type 'exit' to return to devshell."
                ZDOTDIR="$tmp_zdotdir" zsh -i
              else
                echo "Failed to evaluate zsh configuration." >&2
              fi
              rm -rf "$tmp_zdotdir"
            '';
          }
          {
            name = "zsh-reload";
            category = "shell";
            help = "Re-evaluate zsh configuration from shell.nix and export to /tmp/zsh-reload.zsh";
            command = ''
              repo_root="$(git rev-parse --show-toplevel)"
              eval_expr="((builtins.getFlake \"git+file://$repo_root?dir=nixos\").nixosConfigurations.nixos.config.home-manager.users.artifex.programs.zsh.initContent)"
              echo "Evaluating zsh configuration from flake..."
              if nix eval --impure --raw --expr "$eval_expr" > /tmp/zsh-reload.zsh 2>/dev/null; then
                echo "Configuration written to /tmp/zsh-reload.zsh"
                echo "Source it with: source /tmp/zsh-reload.zsh"
              else
                echo "Failed to evaluate zsh configuration." >&2
              fi
            '';
          }
          {
            name = "tv-test";
            category = "television";
            help = "Run television testing repository cables directly without rebuilding";
            command = ''
              repo_root="$(git rev-parse --show-toplevel)"
              eval_expr="((builtins.getFlake \"git+file://$repo_root?dir=nixos\").nixosConfigurations.nixos.config.home-manager.users.artifex.xdg.configFile)"
              tmp_cables=$(mktemp -d /tmp/tv-cables.XXXXXX)
              echo "Evaluating television cables from flake..."
              if nix eval --impure --json --expr "builtins.attrNames $eval_expr" > /tmp/cables.json 2>/dev/null; then
                for k in $(jq -r '.[] | select(startswith("television/cable/"))' /tmp/cables.json); do
                  fname=$(basename "$k")
                  nix eval --impure --raw --expr "($eval_expr).\"$k\".text" > "$tmp_cables/$fname" 2>/dev/null
                done
                rm -f /tmp/cables.json
                echo "Starting television with repository cables ($tmp_cables)..."
                tv --cable-dir "$tmp_cables" "$@"
              else
                echo "Failed to evaluate television cables." >&2
              fi
              rm -rf "$tmp_cables"
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
          {
            name = "YAZI_CONFIG_HOME";
            eval = "$([ -d \"$PRJ_ROOT/config/yazi\" ] && echo \"$PRJ_ROOT/config/yazi\" || echo \"$PRJ_ROOT/../config/yazi\")";
          }
        ];
      };
    };
}
