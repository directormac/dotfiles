# Tmux Aspect with Plugins, Status Bar, and Systemd Socket Autostart
#
# The heavy lifting is split across the sibling modules in `./tmux/`:
#   * `_config.nix`   - `programs.tmux` options and the main tmux.conf body
#   * `_plugins.nix`  - the `programs.tmux.plugins` list
#   * `_systemd.nix`  - the `systemd.user.services.tmux-server` unit
#   * `_packages.nix` - pinned tmux builds exposed through `perSystem`
#   * `_neovim.nix`   - the tmux tree-sitter grammar for Neovim
{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    tmux-fzf-links = {
      flake = false;
      url = "github:alberti42/tmux-fzf-links";
    };

    tmux-menus = {
      flake = false;
      url = "github:jaclu/tmux-menus";
    };

    tmux-nerd-font-window-name.url = "github:joshmedeski/tmux-nerd-font-window-name";
    tmux-remux.url = "github:noamsto/tmux-remux";

    tmux-src = {
      flake = false;
      url = "github:tmux/tmux";
    };
  };

  den.aspects.applications.dev.mux.tmux = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          (pkgs.local.tmux or pkgs.tmux)
        ]
        ++ lib.optional (pkgs ? local && pkgs.local ? tmuxx) pkgs.local.tmuxx
        ++ lib.optionals (pkgs ? nur && pkgs.nur ? repos && pkgs.nur.repos ? Freed-Wu) [
          pkgs.nur.repos.Freed-Wu.tree-sitter-tmux
          pkgs.nur.repos.Freed-Wu.tmux-language-server
          pkgs.nur.repos.Freed-Wu.termux-language-server
        ];
      };

    homeManager =
      {
        config,
        pkgs,
        ...
      }:
      let
        ctx = {
          inherit
            inputs
            kanjiIndex
            lib
            pkgs
            resurrectDir
            resurrectRestoreScript
            resurrectSaveScript
            tmuxPkg
            windowIcon
            windowNumber
            ;
        };
        kanjiIndex = "#{?#{==:#I,1},一,#{==:#I,2},二,#{==:#I,3},三,#{==:#I,4},四,#{==:#I,5},五,#{==:#I,6},六,#{==:#I,7},七,#{==:#I,8},八,#{==:#I,9},九,#{==:#I,10},十,#I}";
        resurrectDir = "${config.home.homeDirectory}/.local/state/tmux/resurrect";
        resurrectPath = lib.makeBinPath [
          tmuxPkg
          pkgs.coreutils
          pkgs.findutils
          pkgs.gnugrep
          pkgs.gnused
          pkgs.gawk
          pkgs.procps
          pkgs.util-linux
          pkgs.diffutils
        ];
        resurrectRestoreScript = pkgs.writeShellScript "tmux-resurrect-restore" ''
          export PATH="${resurrectPath}:$PATH"
          resurrect_dir="${resurrectDir}"
          mkdir -p "$resurrect_dir"

          exec 9>"$resurrect_dir/.restore.lock"
          flock -n 9 || exit 0

          if [ "''${1:-}" != "manual" ] && [ "$(tmux show-option -gqv @resurrect-auto-restored 2>/dev/null)" = "1" ]; then
            exit 0
          fi

          # Self-heal `last` before restore if missing, dangling, or empty.
          if [ ! -f "$resurrect_dir/last" ] || ! grep -q '^pane' "$resurrect_dir/last" 2>/dev/null; then
            for candidate in $(ls -1t "$resurrect_dir"/tmux_resurrect_*.txt 2>/dev/null); do
              if grep -q '^pane' "$candidate" 2>/dev/null; then
                ln -sf "$(basename "$candidate")" "$resurrect_dir/last"
                break
              fi
            done
          fi

          if [ -f "$resurrect_dir/last" ] && grep -q '^pane' "$resurrect_dir/last" 2>/dev/null; then
            tmux set-option -gq @resurrect-auto-restored 1 2>/dev/null || true
            ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/restore.sh
            tmux set-option -gq "@continuum-save-last-timestamp" "$(date +%s)" 2>/dev/null || true
          fi
        '';
        resurrectSaveScript = pkgs.writeShellScript "tmux-resurrect-save" ''
          export PATH="${resurrectPath}:$PATH"
          resurrect_dir="${resurrectDir}"
          mkdir -p "$resurrect_dir"

          # Serialize all save operations so concurrent saves (e.g. client-detached
          # hook + systemd ExecStop on shutdown) never race on `last`.
          exec 9>"$resurrect_dir/.save.lock"
          flock -n 9 || exit 0

          # Refuse to save when the server has no live panes (e.g. empty server on
          # boot before restore completes, or systemd user shutdown after pane
          # transient scopes have already stopped).
          pane_count="$(tmux list-panes -a 2>/dev/null | wc -l | tr -d ' ')"
          if [ -z "$pane_count" ] || [ "$pane_count" -eq 0 ]; then
            exit 0
          fi

          # Avoid same-second filename collision with `last`: save.sh names files
          # with 1-second resolution (`tmux_resurrect_%Y%m%dT%H%M%S.txt`) and
          # deletes the new file when `cmp -s "$resurrect_file_path" "$last"` is
          # true. If `last` already points to this second's filename, `cmp -s`
          # compares the file with itself and `rm`s it, leaving `last` dangling.
          now_file="tmux_resurrect_$(date +"%Y%m%dT%H%M%S").txt"
          if [ -L "$resurrect_dir/last" ] && [ "$(readlink "$resurrect_dir/last")" = "$now_file" ]; then
            sleep 1
          fi

          ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh "$@"

          # Self-heal `last` if missing, dangling, or pointing to a file without panes.
          if [ ! -f "$resurrect_dir/last" ] || ! grep -q '^pane' "$resurrect_dir/last" 2>/dev/null; then
            for candidate in $(ls -1t "$resurrect_dir"/tmux_resurrect_*.txt 2>/dev/null); do
              if grep -q '^pane' "$candidate" 2>/dev/null; then
                ln -sf "$(basename "$candidate")" "$resurrect_dir/last"
                break
              fi
            done
          fi
        '';
        tmuxPkg = pkgs.local.tmux or pkgs.tmux;
        windowIcon = "#{?#{&&:#{!=:#{@workmux_status},},#{||:#{m:*●*,#W},#{m:**,#W},#{m:*󰏿*,#W},#{m:*󱙺*,#W}}},#{@workmux_status},#W#{?@workmux_status, #{@workmux_status},}}";
        windowNumber = "#{?#{!=:#{@window_number_format},},#{E:@window_number_format},${kanjiIndex}}";
      in
      {
        programs.tmux = import ./tmux/_config.nix ctx // import ./tmux/_plugins.nix ctx;

        xdg.configFile = {
          "tmux/scripts" = {
            force = true;
            source = config.lib.dots.link "tmux/scripts";
          };

          "tmux/status.tmux.conf".source = config.lib.dots.link "tmux/status.tmux.conf";

          "tmux/tmux-nerd-font-window-name.yml".source =
            config.lib.dots.link "tmux/tmux-nerd-font-window-name.yml";
        };
      }
      // import ./tmux/_systemd.nix ctx;

    nixpkgs-overlays =
      _:
      lib.optionals (inputs ? tmux-nerd-font-window-name) [
        (final: prev: {
          tmuxPlugins = prev.tmuxPlugins // {
            tmux-nerd-font-window-name =
              inputs.tmux-nerd-font-window-name.packages.${final.stdenv.hostPlatform.system}.default
              .overrideAttrs
                (old: {
                  patches = (old.patches or [ ]) ++ [
                    ./tmux/tmux-nerd-font-window-name-sidebar.patch
                  ];
                });
          };
        })
      ]
      ++ lib.optionals (inputs ? nur) [
        (
          final: prev:
          let
            baseNur = prev.nur or (inputs.nur.overlays.default final prev).nur;
            freedWu = baseNur.repos.Freed-Wu;
            lsp-tree-sitter = relaxUvBuild freedWu.lsp-tree-sitter;
            # Freed-Wu's lsp-tree-sitter, tmux-language-server, and
            # termux-language-server pin `uv_build<0.12` in pyproject.toml,
            # which fails pypaBuildPhase's build-system check against
            # nixpkgs' uv-build >= 0.12.
            relaxUvBuild =
              pkg:
              pkg.overridePythonAttrs (old: {
                pypaBuildFlags = lib.unique ((old.pypaBuildFlags or [ ]) ++ [ "--skip-dependency-check" ]);
              });
            withPatchedLspTreeSitter =
              pkg:
              (relaxUvBuild pkg).overridePythonAttrs (old: {
                propagatedBuildInputs = map (
                  dep: if (dep.pname or "") == "lsp-tree-sitter" then lsp-tree-sitter else dep
                ) (old.propagatedBuildInputs or [ ]);
              });
          in
          {
            nur = baseNur // {
              repos = baseNur.repos // {
                Freed-Wu = freedWu // {
                  inherit lsp-tree-sitter;
                  termux-language-server = withPatchedLspTreeSitter freedWu.termux-language-server;
                  tmux-language-server = withPatchedLspTreeSitter freedWu.tmux-language-server;
                };
              };
            };
          }
        )
      ];

    persistHome.directories = [
      ".local/share/tmux"
      ".local/state/tmux"
    ];
  };

  flake.wrappers.neovim = import ./tmux/_neovim.nix { inherit inputs lib; };
  perSystem = import ./tmux/_packages.nix { inherit inputs; };
}
