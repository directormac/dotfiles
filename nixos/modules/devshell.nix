{
  perSystem =
    {
      config,
      pkgs,
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
        ];

        commands = [
          {
            name = "age";
            command = "rage \"$@\"";
            help = "alias for rage";
          }
          {
            name = "tmux-reload";
            category = "multiplexer";
            help = "Quickly reload the active tmux session from multiplexer.nix without rebuilding";
            command = ''
              repo_root="$(git rev-parse --show-toplevel)"
              eval_expr="((builtins.getFlake \"git+file://$repo_root?dir=nixos\").nixosConfigurations.nixos.config.home-manager.users.artifex.xdg.configFile.\"tmux/tmux.conf\").text"
              conf=$(mktemp /tmp/tmux-conf.XXXXXX)
              echo "Evaluating tmux configuration from flake..."
              if nix eval --impure --raw --expr "$eval_expr" > "$conf" 2>/dev/null; then
                tmux source-file "$conf"
                echo "Tmux reloaded with latest configuration from multiplexer.nix!"
              else
                echo "Failed to evaluate tmux configuration." >&2
              fi
              rm -f "$conf"
            '';
          }
          {
            name = "tmux-test";
            category = "multiplexer";
            help = "Run an isolated test tmux session using multiplexer.nix without rebuilding";
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
