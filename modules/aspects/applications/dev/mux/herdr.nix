# Herdr Multiplexer Aspect: LLM Agents management service and out-of-store config symlink
{
  inputs,
  ...
}:
{
  den.aspects.applications.dev.mux.herdr = {
    homeManager =
      {
        config,
        pkgs,
        ...
      }:
      let
        herdr-plugins-sync = pkgs.writeShellScriptBin "herdr-plugins-sync" ''
          set -euo pipefail
          echo "==> Syncing declarative Herdr plugins..."
          PLUGINS=(
            "natori-hrj/herdr-lazy"
          )
          INSTALLED=$(${herdrPkg}/bin/herdr plugin list --json 2>/dev/null || echo '{"result":{"plugins":[]}}')

          for plugin in "''${PLUGINS[@]}"; do
            repo_name="''${plugin#*/}"
            has_plugin=$(echo "$INSTALLED" | ${pkgs.jq}/bin/jq -r --arg p "$plugin" --arg r "$repo_name" '
              .result.plugins[]? | select(
                (.source.github.repo == $r) or
                (.plugin_id == $r) or
                (.plugin_id == ("cloudmanic." + $r)) or
                (.plugin_id == ("herdr." + $r))
              ) | .plugin_id
            ')

            if [ -n "$has_plugin" ]; then
              echo "  [ok] $plugin (id: $has_plugin) is installed"
            else
              echo "  [installing] $plugin..."
              ${herdrPkg}/bin/herdr plugin install -y "$plugin" || echo "  [warn] failed to install $plugin"
            fi
          done

          NFTN_DIR=$(find "$HOME/.config/herdr/plugins/github-installations" -maxdepth 3 -type d -name "checkout" 2>/dev/null | grep "herdr-nerd-font-tab-name" | head -n 1 || true)
          if [ -n "$NFTN_DIR" ] && [ -d "$NFTN_DIR" ]; then
            if ! grep -q "NUMBER_MAPS" "$NFTN_DIR/lib/nftn/labels.py" 2>/dev/null; then
              echo "  [patching] herdr-nerd-font-tab-name with custom numeral styles..."
              ${pkgs.git}/bin/git -C "$NFTN_DIR" apply "$HOME/.dotfiles/config/herdr/patches/herdr-nerd-font-tab-name-numerals.patch" 2>/dev/null || true
            fi
          fi

          # Ensure agent integrations for herdr
          for integ in omp opencode antigravity-cli; do
            ${herdrPkg}/bin/herdr integration install "$integ" 2>/dev/null || true
          done

          echo "==> Herdr plugins sync complete."
        '';
        herdr-sesh = pkgs.writeShellScriptBin "herdr-sesh" ''
          SESH_BIN=$(find "$HOME/.config/herdr/plugins/github-installations" -maxdepth 5 -type f -name "herdr-sesh" 2>/dev/null | head -n 1)
          if [ -n "$SESH_BIN" ] && [ -x "$SESH_BIN" ]; then
            exec "$SESH_BIN" "$@"
          else
            exec ${herdrPkg}/bin/herdr plugin action invoke fullerzz.sesh.open-picker "$@"
          fi
        '';
        herdrPkg =
          inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr
            or (pkgs.writeShellScriptBin "herdr" "echo herdr");
      in
      {
        home.file.".config/herdr-sesh/config.toml".source =
          config.lib.dots.link "config/herdr-sesh/config.toml";

        home.file.".config/herdr/config.toml".source = config.lib.dots.link "herdr/config.toml";

        home.file.".config/herdr/herdr-nerd-font-tab-name.yml".source =
          config.lib.dots.link "herdr/herdr-nerd-font-tab-name.yml";

        home.file.".config/herdr/plugins/config/cloudmanic.herdr-plus".source =
          config.lib.dots.link "herdr/plugins/config/cloudmanic.herdr-plus";

        home.file.".config/herdr/plugins/config/fullerzz.sesh/config.toml".source =
          config.lib.dots.link "config/herdr-sesh/config.toml";

        home.file.".config/herdr/plugins/config/herdr-bar/config.json".source =
          config.lib.dots.link "herdr/plugins/config/herdr-bar/config.json";

        home.file.".config/herdr/plugins/config/herdr-floax/floax.conf".source =
          config.lib.dots.link "herdr/plugins/config/herdr-floax/floax.conf";

        home.file.".config/herdr/plugins/config/herdr-lazy/plugins.list".source =
          config.lib.dots.link "herdr/plugins/config/herdr-lazy/plugins.list";

        home.file.".config/herdr/scripts".source = config.lib.dots.link "herdr/scripts";

        home.packages = [
          herdrPkg
          herdr-plugins-sync
          herdr-sesh
          pkgs.dtach
        ];

        home.sessionPath = [
          "$HOME/.herdr-projects/data/bin"
          "$HOME/.local/bin"
        ];

        programs.zsh.initContent = ''
          if [ -d "$HOME/.herdr-projects/data/bin" ]; then
            path=("$HOME/.herdr-projects/data/bin" $path)
          fi
          if [ -d "$HOME/.local/bin" ]; then
            path=("$HOME/.local/bin" $path)
          fi
        '';

        systemd.user.services.herdr-server = {
          Install.WantedBy = [ "graphical-session.target" ];

          Service = {
            ExecStart = "${herdrPkg}/bin/herdr server";
            KillMode = "mixed";
            Restart = "on-failure";
            Type = "simple";
          };

          Unit = {
            After = [ "graphical-session.target" ];
            Description = "Herdr Server";
            Documentation = "herdr --help";
          };
        };

      };

    persistHome.directories = [
      ".config/herdr"
      ".herdr-projects"
      ".local/share/herdr"
      ".local/state/herdr"
    ];
  };
}
