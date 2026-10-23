# Cross-multiplexer session launch helpers, television channels, and desktop entries.
#
# One place defines how a launcher attaches to the *most recent* session for
# tmux, zellij, herdr, and tuios. The same helper backs the television channels
# so the picker and the launcher never disagree about session semantics.
{
  den.aspects.applications.dev.mux.sessions = {
    homeManager =
      {
        pkgs,
        ...
      }:
      let
        awk = "${pkgs.gawk}/bin/awk";
        jq = "${pkgs.jq}/bin/jq";
        mux-session-attach = pkgs.writeShellScriptBin "mux-session-attach" ''
          set -u

          tool="''${1:-}"
          [ "$#" -gt 0 ] && shift
          name="''${1:-}"

          die() {
            printf 'mux-session-attach: %s\n' "$*" >&2
            exit 1
          }

          tmux_attach() {
            target="$1"
            command -v tmux >/dev/null 2>&1 || die "tmux is not installed"
            if [ -n "$target" ]; then
              if [ -n "''${TMUX:-}" ]; then
                exec tmux switch-client -t "$target"
              fi
              exec tmux attach -t "$target"
            fi
            if tmux list-sessions >/dev/null 2>&1; then
              if [ -n "''${TMUX:-}" ]; then
                exec tmux switch-client
              fi
              exec tmux attach
            fi
            exec tmux new-session
          }

          zellij_attach() {
            target="$1"
            command -v zellij >/dev/null 2>&1 || die "zellij is not installed"
            if [ -z "$target" ]; then
              target="$(zellij ls -s -r 2>/dev/null | head -n1 || true)"
            fi
            if [ -n "''${ZELLIJ:-}" ] && [ -n "$target" ]; then
              exec zellij action switch-session "$target"
            fi
            if [ -n "$target" ]; then
              exec zellij attach "$target"
            fi
            exec zellij
          }

          herdr_attach() {
            target="$1"
            command -v herdr >/dev/null 2>&1 || die "herdr is not installed"
            if [ -z "$target" ]; then
              target="$(herdr session list --json 2>/dev/null | ${jq} -r '
                [.sessions[]? | select(.running)] as $running
                | (($running | map(select(.default)) | first | .name)
                   // ($running | last | .name)
                   // empty)
              ' 2>/dev/null || true)"
            fi
            if [ -n "$target" ]; then
              exec herdr session attach "$target"
            fi
            exec herdr
          }

          tuios_attach() {
            target="$1"
            command -v tuios >/dev/null 2>&1 || die "tuios is not installed"
            if [ -n "''${TUIOS_SESSION:-}" ]; then
              if [ -z "$target" ]; then
                target="$(tuios ls --json 2>/dev/null | ${jq} -r '
                  sort_by(.created) | last | .name // empty
                ' 2>/dev/null || true)"
              fi
              if [ -n "$target" ]; then
                exec tuios switch-session "$target"
              fi
              exec tuios new
            fi
            if [ -n "$target" ]; then
              exec tuios attach "$target"
            fi
            exec tuios attach
          }

          case "$tool" in
            tmux) tmux_attach "$name" ;;
            zellij) zellij_attach "$name" ;;
            herdr) herdr_attach "$name" ;;
            tuios) tuios_attach "$name" ;;
            *) die "usage: mux-session-attach <tmux|zellij|herdr|tuios> [session]" ;;
          esac
        '';
        mux-session-preview = pkgs.writeShellScriptBin "mux-session-preview" ''
          set -u
          tool="''${1:-}"
          name="''${2:-}"
          [ -n "$name" ] || exit 0

          case "$tool" in
            tmux)
              printf 'tmux session: %s\n\n' "$name"
              tmux list-windows -t "$name" \
                -F '  #{window_index}: #{window_name} (#{window_panes} panes)#{?window_active, [active],}' \
                2>/dev/null || true
              ;;
            zellij)
              printf 'zellij session: %s\n\n' "$name"
              zellij ls -n 2>/dev/null | grep -F -- "$name" || true
              ;;
            herdr)
              herdr session list --json 2>/dev/null | ${jq} -r --arg n "$name" '
                .sessions[]?
                | select(.name == $n)
                | "session: \(.name)\nrunning: \(.running)\ndefault: \(.default)\ndir: \(.session_dir // "")"
              ' 2>/dev/null || true
              herdr --session "$name" workspace list 2>/dev/null | ${jq} -r '
                .result.workspaces[]?
                | "  [\(.workspace_id)] \(.label) (tabs: \(.tab_count), panes: \(.pane_count))"
              ' 2>/dev/null || true
              ;;
            tuios)
              tuios ls --json 2>/dev/null | ${jq} -r --arg n "$name" '
                .[]?
                | select(.name == $n)
                | "session: \(.name)\nwindows: \(.windows // 0)\nclients: \(.clients // 0)\nattached: \(.attached // false)\nsaved: \(.saved // false)"
              ' 2>/dev/null || true
              ;;
            *)
              printf '%s: %s\n' "$tool" "$name"
              ;;
          esac
        '';
        tv-herdr-sessions-source = pkgs.writeShellScriptBin "tv-herdr-sessions-source" ''
          set -u
          command -v herdr >/dev/null 2>&1 || exit 0
          herdr session list --json 2>/dev/null | ${jq} -r '
            .sessions[]?
            | [
                .name,
                (if .running then "running" else "stopped" end),
                (if .default then "default session" else "session" end)
              ]
            | @tsv
          ' 2>/dev/null || true
          exit 0
        '';
        tv-sessions-source = pkgs.writeShellScriptBin "tv-sessions-source" ''
          set -u
          prefixed() {
            tool="$1"
            shift
            "$@" 2>/dev/null | ${awk} -v OFS='\t' -v t="$tool" '{ print t, $0 }'
          }
          command -v tmux >/dev/null 2>&1 && prefixed tmux ${tv-tmux-sessions-source}/bin/tv-tmux-sessions-source
          command -v zellij >/dev/null 2>&1 && prefixed zellij ${tv-zellij-sessions-source}/bin/tv-zellij-sessions-source
          command -v herdr >/dev/null 2>&1 && prefixed herdr ${tv-herdr-sessions-source}/bin/tv-herdr-sessions-source
          command -v tuios >/dev/null 2>&1 && prefixed tuios ${tv-tuios-sessions-source}/bin/tv-tuios-sessions-source
          exit 0
        '';
        tv-tmux-sessions-source = pkgs.writeShellScriptBin "tv-tmux-sessions-source" ''
          set -u
          command -v tmux >/dev/null 2>&1 || exit 0
          tmux list-sessions \
            -F '#{session_name}|#{session_windows}|#{session_attached}|#{?session_last_attached,#{session_last_attached},#{session_created}}' \
            2>/dev/null \
            | sort -t'|' -k4,4 -rn \
            | while IFS='|' read -r name windows clients last; do
                [ -n "$name" ] || continue
                printf '%s\t%s windows\t%s client(s)\n' "$name" "$windows" "$clients"
              done
          exit 0
        '';
        tv-tuios-sessions-source = pkgs.writeShellScriptBin "tv-tuios-sessions-source" ''
          set -u
          command -v tuios >/dev/null 2>&1 || exit 0
          tuios ls --json 2>/dev/null | ${jq} -r '
            .[]?
            | [
                .name,
                ((.windows // 0 | tostring) + " windows"),
                (if .saved then "saved"
                 elif .attached then ((.clients // 0 | tostring) + " client(s)")
                 else "detached" end)
              ]
            | @tsv
          ' 2>/dev/null || true
          exit 0
        '';
        tv-zellij-sessions-source = pkgs.writeShellScriptBin "tv-zellij-sessions-source" ''
          set -u
          command -v zellij >/dev/null 2>&1 || exit 0
          zellij ls -n -r 2>/dev/null \
            | sed -E 's/ \[Created (.*)\] *$/|\1/' \
            | while IFS='|' read -r name created; do
                [ -n "$name" ] || continue
                printf '%s\tcreated\t%s\n' "$name" "''${created:-unknown}"
              done
          exit 0
        '';
      in
      {
        home.packages = [
          mux-session-attach
          mux-session-preview
          tv-tmux-sessions-source
          tv-zellij-sessions-source
          tv-herdr-sessions-source
          tv-tuios-sessions-source
          tv-sessions-source
        ];

        xdg.desktopEntries = {
          herdr-recent = {
            settings = {
              StartupNotify = "false";
              StartupWMClass = "com.ghostty.mux";
            };

            categories = [
              "Development"
              "TerminalEmulator"
            ];

            comment = "Attach to the default Herdr session";
            exec = "ghostty --class=com.ghostty.mux -e ${mux-session-attach}/bin/mux-session-attach herdr";
            genericName = "Agent Terminal Workspace";
            icon = "utilities-terminal";
            name = "Herdr (Recent Session)";
          };

          mux-sessions = {
            settings = {
              StartupNotify = "false";
              StartupWMClass = "com.ghostty.mux";
            };

            categories = [
              "System"
              "TerminalEmulator"
              "Utility"
            ];

            comment = "Pick and attach to a tmux, zellij, herdr, or tuios session";
            exec = "ghostty --class=com.ghostty.mux -e ${pkgs.television}/bin/tv sessions";
            genericName = "Multiplexer Session Picker";
            icon = "utilities-terminal";
            name = "Sessions";
          };

          tmux-recent = {
            settings = {
              StartupNotify = "false";
              StartupWMClass = "com.ghostty.mux";
            };

            categories = [
              "System"
              "TerminalEmulator"
              "Utility"
            ];

            comment = "Attach to the most recently used tmux session";
            exec = "ghostty --class=com.ghostty.mux -e ${mux-session-attach}/bin/mux-session-attach tmux";
            genericName = "Terminal Multiplexer";
            icon = "utilities-terminal";
            name = "tmux (Recent Session)";
          };

          tuios-recent = {
            settings = {
              StartupNotify = "false";
              StartupWMClass = "com.ghostty.mux";
            };

            categories = [
              "System"
              "TerminalEmulator"
              "Utility"
            ];

            comment = "Attach to the most recent TUIOS session";
            exec = "ghostty --class=com.ghostty.mux -e ${mux-session-attach}/bin/mux-session-attach tuios";
            genericName = "Terminal Window Manager";
            icon = "utilities-terminal";
            name = "TUIOS (Recent Session)";
          };

          zellij-recent = {
            settings = {
              StartupNotify = "false";
              StartupWMClass = "com.ghostty.mux";
            };

            categories = [
              "System"
              "TerminalEmulator"
              "Utility"
            ];

            comment = "Attach to the most recently created zellij session";
            exec = "ghostty --class=com.ghostty.mux -e ${mux-session-attach}/bin/mux-session-attach zellij";
            genericName = "Terminal Multiplexer";
            icon = "utilities-terminal";
            name = "Zellij (Recent Session)";
          };
        };
      };
  };
}
