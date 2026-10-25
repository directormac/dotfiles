# Television Fuzzy Finder Aspect with Custom Cables and Cache Update Timer
# https://github.com/alexpasmantier/television
# https://alexpasmantier.github.io/television/
{
  den.aspects.applications.dev.shell.television = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages =
          with pkgs;
          [
            television
            nix-search-tv
            jq
          ]
          ++ (lib.optionals (pkgs ? local) (
            with pkgs.local;
            [
              rebuild-switch
              nix-generations
              update-pkgs
              nix-flake-update
            ]
          ));
      };

    homeManager =
      {
        config,
        pkgs,
        ...
      }:
      let
        tv-app-launch = pkgs.writeShellScriptBin "tv-app-launch" ''
          action="''${1:-run}"
          file="''${2:-}"

          if [ -z "$file" ] || [ ! -f "$file" ]; then
            echo "Error: valid desktop entry path required" >&2
            exit 1
          fi

          if [ "$action" = "edit" ]; then
            exec "''${EDITOR:-nvim}" "$file"
          fi

          exec_cmd=$(grep -m1 '^Exec=' "$file" | cut -d= -f2- || true)
          terminal=$(grep -m1 '^Terminal=' "$file" | cut -d= -f2- | tr '[:upper:]' '[:lower:]' || true)

          clean_exec=$(echo "$exec_cmd" | sed -E 's/%[a-zA-Z]//g; s/[[:space:]]+$//')

          if [ -z "$clean_exec" ]; then
            echo "Error: no valid Exec command found in $file" >&2
            exit 1
          fi

          case "$action" in
            elevate)
              if [ "$terminal" = "true" ]; then
                setsid -f ghostty -e sudo $clean_exec >/dev/null 2>&1 || true
              else
                setsid -f pkexec-gui $clean_exec >/dev/null 2>&1 || true
              fi
              ;;
            run|*)
              if [ "$terminal" = "true" ]; then
                setsid -f ghostty -e $clean_exec >/dev/null 2>&1 || true
              else
                if [[ "$clean_exec" =~ pkexec ]]; then
                  target_exec=$(echo "$clean_exec" | sed 's/pkexec //')
                  setsid -f pkexec-gui $target_exec >/dev/null 2>&1 || true
                else
                  setsid -f sh -c "$clean_exec" >/dev/null 2>&1 || true
                fi
              fi
              ;;
          esac
        '';
        tv-apps-preview = pkgs.writeShellScriptBin "tv-apps-preview" ''
          file="$1"
          if [ ! -f "$file" ]; then
            echo "Desktop entry not found: $file"
            exit 0
          fi

          name=$(grep -m1 '^Name=' "$file" | cut -d= -f2- || true)
          exec_cmd=$(grep -m1 '^Exec=' "$file" | cut -d= -f2- || true)
          comment=$(grep -m1 '^Comment=' "$file" | cut -d= -f2- || true)
          categories=$(grep -m1 '^Categories=' "$file" | cut -d= -f2- || true)
          terminal=$(grep -m1 '^Terminal=' "$file" | cut -d= -f2- || true)
          icon=$(grep -m1 '^Icon=' "$file" | cut -d= -f2- || true)

          clean_exec=$(echo "$exec_cmd" | sed -E 's/%[a-zA-Z]//g; s/[[:space:]]+$//')

          is_admin=0
          if [[ "$clean_exec" =~ pkexec|sudo ]] || [[ "$categories" =~ System|HardwareSettings|Filesystem ]] || [[ "$file" =~ gsmartcontrol|disk|gparted ]]; then
            is_admin=1
          fi

          echo -e "\033[1;35m==>\033[0m \033[1;37m$name\033[0m"
          if [ "$is_admin" -eq 1 ]; then
            echo -e "\033[1;31m[ADMIN / ELEVATED]\033[0m \033[90mAdministrator privileges supported/recommended\033[0m"
          elif [ "$terminal" = "true" ]; then
            echo -e "\033[1;33m[CLI / TERMINAL]\033[0m \033[90mRuns inside terminal emulator\033[0m"
          else
            echo -e "\033[1;32m[GUI APPLICATION]\033[0m \033[90mStandard desktop application\033[0m"
          fi
          echo ""

          [ -n "$comment" ] && echo -e "\033[1;34mDescription:\033[0m  $comment"
          [ -n "$icon" ] && echo -e "\033[1;34mIcon:\033[0m         $icon"
          [ -n "$categories" ] && echo -e "\033[1;34mCategories:\033[0m   $categories"
          echo -e "\033[1;34mDesktop File:\033[0m \033[90m$file\033[0m"
          echo ""

          echo -e "\033[1;32mNormal Command:\033[0m"
          echo -e "  \033[36m$clean_exec\033[0m"
          echo ""

          echo -e "\033[1;31mElevated Command (pkexec-gui):\033[0m"
          echo -e "  \033[33mpkexec-gui $clean_exec\033[0m"
          echo ""

          echo -e "\033[1;35mActions:\033[0m"
          echo -e "  \033[1m<Enter>\033[0m   Launch normally"
          echo -e "  \033[1;31m<Ctrl+E>\033[0m  Launch with Root / Administrator Elevation (pkexec-gui)"
          echo -e "  \033[1m<Ctrl+Y>\033[0m  Copy launch command to clipboard"
          echo -e "  \033[1m<Ctrl+O>\033[0m  Open desktop file in editor"
        '';
        tv-apps-source = pkgs.writeShellScriptBin "tv-apps-source" ''
                    ${pkgs.python3}/bin/python3 -c '
          import os, glob

          dirs = [
              os.path.expanduser("~/.local/share/applications"),
              os.path.expanduser("/etc/profiles/per-user/" + os.environ.get("USER", "") + "/share/applications"),
              "/run/current-system/sw/share/applications",
          ]

          seen_names = set()
          for d in dirs:
              if not os.path.isdir(d):
                  continue
              for f in sorted(glob.glob(os.path.join(d, "*.desktop"))):
                  base = os.path.basename(f)
                  if base in seen_names:
                      continue
                  seen_names.add(base)

                  name = ""
                  exec_cmd = ""
                  comment = ""
                  categories = ""
                  terminal = False
                  no_display = False
                  in_entry = False

                  try:
                      with open(f, "r", errors="ignore") as fp:
                          for line in fp:
                              line = line.strip()
                              if line == "[Desktop Entry]":
                                  in_entry = True
                                  continue
                              elif line.startswith("[") and in_entry:
                                  break
                              if not in_entry:
                                  continue

                              if line.startswith("Name=") and not name:
                                  name = line[5:]
                              elif line.startswith("Exec=") and not exec_cmd:
                                  exec_cmd = line[5:]
                              elif line.startswith("Comment=") and not comment:
                                  comment = line[8:]
                              elif line.startswith("Categories=") and not categories:
                                  categories = line[11:]
                              elif line.startswith("Terminal="):
                                  terminal = (line[9:].lower() == "true")
                              elif line.startswith("NoDisplay="):
                                  no_display = (line[10:].lower() == "true")
                  except Exception:
                      continue

                  if no_display or not name or not exec_cmd:
                      continue

                  clean_exec = " ".join([arg for arg in exec_cmd.split() if not arg.startswith("%")])

                  is_elevated = (
                      "pkexec" in clean_exec
                      or "sudo" in clean_exec
                      or any(k in categories for k in ["System", "HardwareSettings", "Filesystem"])
                      or any(app in base.lower() for app in ["gsmartcontrol", "disk", "gparted", "wireshark"])
                  )

                  badge = "[ADMIN]" if is_elevated else ("[CLI]" if terminal else "[GUI]")
                  try:
                      print(f"{name}\t{badge}\t{comment}\t{clean_exec}\t{f}")
                  except BrokenPipeError:
                      break
          '
        '';
        tv-channel-enter = pkgs.writeShellScriptBin "tv-channel-enter" ''
          chan="$1"
          if [ -n "''${TV_CMD:-}" ]; then
            cmd_args="''${TV_CMD#tv }"
            exec ${pkgs.television}/bin/tv $cmd_args "$chan"
          else
            exec ${pkgs.television}/bin/tv "$chan"
          fi
        '';
        tv-histdb-preview = pkgs.writeShellScriptBin "tv-histdb-preview" ''
          cmd="$1"
          last_run="$2"
          last_dir="$3"
          db="''${HISTDB_FILE:-$HOME/.local/share/zsh/history.db}"

          echo "$cmd"
          if [ -n "$last_run" ] && [ "$last_run" != "-" ]; then
            echo "last run: $last_run in $last_dir"
          fi

          if [ -f "$db" ] && [ -n "$cmd" ]; then
            echo ""
            echo "recent runs"
            ${pkgs.python3}/bin/python3 -c '
          import sys, sqlite3
          db_path, cmd = sys.argv[1], sys.argv[2]
          try:
              conn = sqlite3.connect(db_path)
              cur = conn.cursor()
              cur.execute("""
                  SELECT
                      datetime(history.start_time, "unixepoch", "localtime"),
                      history.duration,
                      history.exit_status,
                      places.dir
                  FROM history
                  JOIN commands ON history.command_id = commands.id
                  JOIN places ON history.place_id = places.id
                  WHERE commands.argv = ?
                  ORDER BY history.start_time DESC
                  LIMIT 5
              """, (cmd,))
              rows = cur.fetchall()
              for row in rows:
                  time_str, dur, status, d = row
                  status_str = "ok" if status == 0 else f"err {status}" if status is not None else "?"
                  dur_str = f"{dur}s" if dur is not None else "0s"
                  print(f"  {time_str} ({status_str}, {dur_str}) in {d}")
              conn.close()
          except Exception:
              pass
          ' "$db" "$cmd"
          fi
        '';
        tv-histdb-source = pkgs.writeShellScriptBin "tv-histdb-source" ''
          db="''${HISTDB_FILE:-$HOME/.local/share/zsh/history.db}"
          if [ -f "$db" ]; then
            ${pkgs.sqlite}/bin/sqlite3 -batch -noheader -separator $'\t' "$db" "
              SELECT
                replace(replace(commands.argv, char(10), ' '), char(13), ' '),
                datetime(max(history.start_time), 'unixepoch', 'localtime'),
                places.dir
              FROM history
              JOIN commands ON history.command_id = commands.id
              JOIN places ON history.place_id = places.id
              GROUP BY commands.argv
              ORDER BY max(history.start_time) DESC;
            " 2>/dev/null
          elif [ -f "''${HISTFILE:-$HOME/.zsh_history}" ]; then
            ${pkgs.gnused}/bin/sed '1!G;h;$!d' "''${HISTFILE:-$HOME/.zsh_history}" | ${pkgs.gawk}/bin/awk -F';' '{cmd=$0; sub(/^:[^;]*;/, "", cmd); print cmd "\t-\t~"}'
          fi
        '';
        tv-history-delete = pkgs.writeShellScriptBin "tv-history-delete" ''
          target="$1"
          if [ -z "$target" ]; then
            echo "No target command provided." >&2
            exit 1
          fi

          db="''${HISTDB_FILE:-$HOME/.local/share/zsh/history.db}"
          deleted=0

          if [ -f "$db" ]; then
            if ${pkgs.python3}/bin/python3 -c '
          import sys, sqlite3
          db_path, cmd = sys.argv[1], sys.argv[2]
          try:
              conn = sqlite3.connect(db_path)
              cur = conn.cursor()
              cur.execute("DELETE FROM history WHERE command_id IN (SELECT id FROM commands WHERE argv = ?)", (cmd,))
              cur.execute("DELETE FROM commands WHERE argv = ?", (cmd,))
              conn.commit()
              conn.close()
          except Exception:
              sys.exit(1)
          ' "$db" "$target"; then
              deleted=1
            fi
          fi

          histfile="''${HISTFILE:-$HOME/.zsh_history}"
          if [ -f "$histfile" ]; then
            tmp_file=$(mktemp "$histfile.tmp.XXXXXX")
            ${pkgs.gawk}/bin/awk -v exact="$target" '
              $0 == exact { next }
              {
                raw = $0
                stripped = raw
                if (sub(/^:[ \t]*[0-9]+:[0-9]+;/, "", stripped) && stripped == exact) next
                print raw
              }
            ' "$histfile" > "$tmp_file" && mv "$tmp_file" "$histfile" && deleted=1
          fi

          if [ "$deleted" -eq 1 ]; then
            echo "Deleted from history: $target"
          else
            echo "History entry not found: $target" >&2
            exit 1
          fi
        '';
        tv-hypr-client-preview = pkgs.writeShellScriptBin "tv-hypr-client-preview" ''
          addr="$1"
          ${pkgs.hyprland or "hyprctl"}/bin/hyprctl clients -j 2>/dev/null | ${pkgs.jq}/bin/jq -r --arg addr "$addr" '
            .[] | select(.address == $addr) |
            "\(.title)\n" +
            "class: \(.class) (\(.initialClass))\n" +
            "workspace: \(.workspace.name) (id: \(.workspace.id))\n" +
            "monitor: \(.monitor)\n" +
            "address: \(.address)\n" +
            "pid: \(.pid)\n" +
            "floating: \(.floating) | fullscreen: \(.fullscreen)\n" +
            "size: \(.size[0])x\(.size[1]) at \(.at[0]),\(.at[1])"
          '
        '';
        tv-hypr-workspace-preview = pkgs.writeShellScriptBin "tv-hypr-workspace-preview" ''
          ws_id="$1"
          ${pkgs.hyprland or "hyprctl"}/bin/hyprctl clients -j 2>/dev/null | ${pkgs.jq}/bin/jq -r --arg id "$ws_id" '
            [ .[] | select((.workspace.id|tostring) == $id) ] as $clients |
            "workspace " + $id + " (" + ($clients[0].workspace.name // "") + ")\n" +
            "windows: " + ($clients | length | tostring) + "\n\n" +
            "clients\n" +
            (if ($clients | length) == 0 then "  (no windows)\n" else
              ($clients | map("  [" + .class + "] " + .title) | join("\n")) + "\n"
            end)
          '
        '';
        tv-media-player-preview = pkgs.writeShellScriptBin "tv-media-player-preview" ''
          p="$1"
          echo "player: $p"
          echo "status: $(${pkgs.playerctl}/bin/playerctl -p "$p" status 2>/dev/null)"
          echo "title:  $(${pkgs.playerctl}/bin/playerctl -p "$p" metadata title 2>/dev/null)"
          echo "artist: $(${pkgs.playerctl}/bin/playerctl -p "$p" metadata artist 2>/dev/null)"
          echo "album:  $(${pkgs.playerctl}/bin/playerctl -p "$p" metadata album 2>/dev/null)"
          pos=$(${pkgs.playerctl}/bin/playerctl -p "$p" position 2>/dev/null)
          [ -n "$pos" ] && echo "position: ''${pos}s"
        '';
        tv-pkgs-preview = pkgs.writeShellScriptBin "tv-pkgs-preview" ''
          pkg="$1"
          repo="$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/.dotfiles")"
          file="$repo/pkgs/by-name/$pkg/package.nix"
          echo -e "\033[1;34m==>\033[0m \033[1mPackage:\033[0m $pkg"
          echo -e "\033[1;34m==>\033[0m \033[1mPath:\033[0m pkgs/by-name/$pkg/package.nix"
          echo ""
          echo -e "\033[1;32mRecent Git Commits:\033[0m"
          git -C "$repo" log -n 3 --oneline -- "pkgs/by-name/$pkg" 2>/dev/null || echo "  (no commits)"
          echo ""
          echo -e "\033[1;33mDefinition Preview:\033[0m"
          if command -v bat >/dev/null 2>&1; then
            bat -pn --color=always -r :40 "$file" 2>/dev/null || head -n 40 "$file"
          else
            head -n 40 "$file"
          fi
        '';
        tv-pkgs-source = pkgs.writeShellScriptBin "tv-pkgs-source" ''
          repo="$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/.dotfiles")"
          for d in "$repo"/pkgs/by-name/*; do
            [ -d "$d" ] || continue
            pkg="$(basename "$d")"
            ver="$(grep -m1 'version = ' "$d/package.nix" 2>/dev/null | sed -E 's/.*version = "([^"]+)".*/\1/' || true)"
            [ -z "$ver" ] && ver="local"
            printf "%s\t%s\n" "$pkg" "$ver"
          done
        '';
        tv-cheatsheets-list = pkgs.writeShellScriptBin "tv-cheatsheets-list" ''
          cheatsheets_dir="''${HOME}/.dotfiles/config/DankMaterialShell/cheatsheets"
          [ ! -d "$cheatsheets_dir" ] && cheatsheets_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/dms/cheatsheets"

          ${pkgs.python3}/bin/python3 - "$cheatsheets_dir" <<'EOF'
          import json, sys, subprocess
          from pathlib import Path

          cheatsheets_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.home() / ".config/dms/cheatsheets"

          available = set()
          try:
              res = subprocess.run(["dms", "keybinds", "list", "-j"], capture_output=True, text=True, timeout=2)
              if res.returncode == 0:
                  available = set(json.loads(res.stdout))
          except Exception:
              pass

          order = ["hyprland", "yazi", "neovim", "tmux", "ghostty", "kitty", "zsh", "herdr", "vim"]
          providers = []
          for p in order:
              if p in available or (cheatsheets_dir / f"{p}.json").exists() or p == "hyprland":
                  providers.append(p)

          for p in sorted(available):
              if p not in providers and (cheatsheets_dir / f"{p}.json").exists():
                  providers.append(p)

          for p in providers:
              title = p.capitalize()
              count = 0
              cat_count = 0
              json_path = cheatsheets_dir / f"{p}.json"
              if json_path.exists():
                  try:
                      with open(json_path, encoding="utf-8") as f:
                          data = json.load(f)
                          title = data.get("title", title)
                          binds = data.get("binds", {})
                          cat_count = len(binds)
                          count = sum(len(v) for v in binds.values())
                  except Exception:
                      pass
              elif p == "hyprland":
                  try:
                      res = subprocess.run(["dms", "keybinds", "show", "hyprland"], capture_output=True, text=True, timeout=2)
                      if res.returncode == 0:
                          data = json.loads(res.stdout)
                          title = data.get("title", "Hyprland Keybinds")
                          binds = data.get("binds", {})
                          cat_count = len(binds)
                          count = sum(len(v) for v in binds.values())
                  except Exception:
                      pass
              try:
                  print(f"{p}\t{title}\t{count} shortcuts\t{cat_count} categories")
              except BrokenPipeError:
                  break
          EOF
        '';
        tv-cheatsheet-preview = pkgs.writeShellScriptBin "tv-cheatsheet-preview" ''
          provider="''${1:-hyprland}"
          cheatsheets_dir="''${HOME}/.dotfiles/config/DankMaterialShell/cheatsheets"
          [ ! -d "$cheatsheets_dir" ] && cheatsheets_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/dms/cheatsheets"

          ${pkgs.python3}/bin/python3 - "$cheatsheets_dir" "$provider" <<'EOF'
          import json, sys, subprocess
          from pathlib import Path

          cheatsheets_dir = Path(sys.argv[1])
          provider = sys.argv[2] if len(sys.argv) > 2 else "hyprland"
          json_path = cheatsheets_dir / f"{provider}.json"

          data = None
          if json_path.exists():
              try:
                  with open(json_path, "r", encoding="utf-8") as f:
                      data = json.load(f)
              except Exception:
                  pass

          if not data:
              try:
                  res = subprocess.run(["dms", "keybinds", "show", provider], capture_output=True, text=True, timeout=3)
                  if res.returncode == 0:
                      data = json.loads(res.stdout)
              except Exception:
                  pass

          if not data:
              print(f"\033[1;31mError:\033[0m Could not load cheatsheet for '\033[1m{provider}\033[0m'")
              print("Verify provider is registered with `dms keybinds list`.")
              sys.exit(0)

          title = data.get("title", provider.capitalize() + " Keybinds")
          binds = data.get("binds", {})
          total_binds = sum(len(v) for v in binds.values())

          BOLD = "\033[1m"
          RESET = "\033[0m"
          CYAN = "\033[36m"
          GREEN = "\033[32m"
          YELLOW = "\033[33m"
          MAGENTA = "\033[35m"
          GRAY = "\033[90m"

          print(f"{BOLD}{MAGENTA}==> {title} ({provider}){RESET}")
          print(f"{GRAY}Launch GUI:\033[0m {CYAN}dms ipc call keybinds toggle {provider}{RESET}")
          print(f"{GRAY}Scope:     \033[0m {GREEN}{total_binds} shortcuts{RESET} across {YELLOW}{len(binds)} categories{RESET}")
          print(f"{GRAY}Actions:   \033[0m {BOLD}<Enter>{RESET} Launch DMS modal  │  {BOLD}<Ctrl+Y>{RESET} Copy provider  │  {BOLD}<Ctrl+O>{RESET} Pager\n")

          for cat, items in binds.items():
              print(f"{BOLD}{YELLOW}── {cat} ({len(items)}) ──{RESET}")
              for item in items:
                  key = item.get("key", "")
                  desc = item.get("desc", item.get("action", ""))
                  sub = item.get("subcat", "")
                  sub_str = f" {GRAY}[{sub}]{RESET}" if sub else ""
                  print(f"  {BOLD}{GREEN}{key:<22}{RESET} {desc}{sub_str}")
              print()
          EOF
        '';
        tv-cheatsheet-launch = pkgs.writeShellScriptBin "tv-cheatsheet-launch" ''
          provider="''${1:-}"
          if [ -z "$provider" ]; then
            echo "Error: provider name required" >&2
            exit 1
          fi

          if command -v dms >/dev/null 2>&1; then
            dms ipc call keybinds toggle "$provider" || {
              ${pkgs.libnotify}/bin/notify-send -u low "DMS Cheatsheet" "Failed to toggle keybinds for $provider"
            }
          else
            echo "Error: dms command not found" >&2
            exit 1
          fi
        '';
        tv-cheatsheet-view = pkgs.writeShellScriptBin "tv-cheatsheet-view" ''
          provider="''${1:-hyprland}"
          tv-cheatsheet-preview "$provider" | ${pkgs.less}/bin/less -R
        '';
        tv-cheatsheet-edit = pkgs.writeShellScriptBin "tv-cheatsheet-edit" ''
          provider="''${1:-}"
          file="$HOME/.dotfiles/config/DankMaterialShell/cheatsheets/$provider.json"
          if [ -f "$file" ]; then
            exec "''${EDITOR:-nvim}" "$file"
          else
            echo "Cheatsheet JSON for $provider not found in dotfiles."
            read -r -p "Press enter to continue..."
          fi
        '';
        tv-keybinds-list = pkgs.writeShellScriptBin "tv-keybinds-list" ''
          cheatsheets_dir="''${HOME}/.dotfiles/config/DankMaterialShell/cheatsheets"
          [ ! -d "$cheatsheets_dir" ] && cheatsheets_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/dms/cheatsheets"

          ${pkgs.python3}/bin/python3 - "$cheatsheets_dir" <<'EOF'
          import json, sys, subprocess
          from pathlib import Path

          cheatsheets_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.home() / ".config/dms/cheatsheets"
          order = ["hyprland", "yazi", "neovim", "tmux", "ghostty", "kitty", "zsh", "herdr", "vim"]

          for p in order:
              data = None
              json_path = cheatsheets_dir / f"{p}.json"
              if json_path.exists():
                  try:
                      with open(json_path, encoding="utf-8") as f:
                          data = json.load(f)
                  except Exception:
                      pass
              elif p == "hyprland":
                  try:
                      res = subprocess.run(["dms", "keybinds", "show", "hyprland"], capture_output=True, text=True, timeout=2)
                      if res.returncode == 0:
                          data = json.loads(res.stdout)
                  except Exception:
                      pass
              if not data:
                  continue
              binds = data.get("binds", {})
              for cat, items in binds.items():
                  for item in items:
                      key = item.get("key", "").strip()
                      desc = item.get("desc", item.get("action", "")).strip()
                      sub = item.get("subcat", "").strip()
                      try:
                          print(f"{p}\t{cat}\t{key}\t{desc}\t{sub}")
                      except BrokenPipeError:
                          sys.exit(0)
          EOF
        '';
        tv-keybind-preview = pkgs.writeShellScriptBin "tv-keybind-preview" ''
          provider="''${1:-}"
          cat="''${2:-}"
          key="''${3:-}"
          desc="''${4:-}"
          sub="''${5:-}"

          BOLD="\033[1m"
          RESET="\033[0m"
          CYAN="\033[36m"
          GREEN="\033[32m"
          YELLOW="\033[33m"
          MAGENTA="\033[35m"
          GRAY="\033[90m"

          echo -e "''${BOLD}''${MAGENTA}==> Shortcut Details''${RESET}"
          echo -e "''${GRAY}Provider:   ''${RESET}''${BOLD}''${CYAN}$provider''${RESET}"
          echo -e "''${GRAY}Category:   ''${RESET}''${YELLOW}$cat''${RESET}''${sub:+ ''${GRAY}[''${RESET}$sub''${GRAY}]''${RESET}}"
          echo -e "''${GRAY}Key Combo:  ''${RESET}''${BOLD}''${GREEN}$key''${RESET}"
          echo -e "''${GRAY}Action/Desc:''${RESET} $desc"
          echo ""
          echo -e "''${GRAY}Actions:''${RESET}"
          echo -e "  ''${BOLD}<Enter>''${RESET} Open $provider cheatsheet in DMS GUI (dms ipc call keybinds toggle $provider)"
          echo -e "  ''${BOLD}<Ctrl+Y>''${RESET} Copy key combination ($key)"
          echo -e "  ''${BOLD}<Alt+Y>''${RESET} Copy description"
        '';
        which-key = pkgs.writeShellScriptBin "which-key" ''
          exec ${pkgs.ghostty}/bin/ghostty --class=com.ghostty.float -e ${pkgs.television}/bin/tv cheatsheets
        '';
      in
      {
        home.packages =
          with pkgs;
          [
            nix-search-tv
            tv-channel-enter
            tv-histdb-preview
            tv-histdb-source
            tv-history-delete
            tv-hypr-client-preview
            tv-hypr-workspace-preview
            tv-media-player-preview
            tv-pkgs-source
            tv-pkgs-preview
            tv-apps-source
            tv-apps-preview
            tv-app-launch
            tv-cheatsheets-list
            tv-cheatsheet-preview
            tv-cheatsheet-launch
            tv-cheatsheet-view
            tv-cheatsheet-edit
            tv-keybinds-list
            tv-keybind-preview
            which-key
          ]
          ++ (lib.optionals (pkgs ? local) (
            with pkgs.local;
            [
              rebuild-switch
              nix-generations
              update-pkgs
              nix-flake-update
            ]
          ));

        programs.nix-search-tv = {
          enable = true;
          enableTelevisionIntegration = true;
        };

        programs.television = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };

        systemd.user.services.update-cli-caches = {
          Service = {
            ExecStart = [
              "${pkgs.tealdeer}/bin/tldr --update"
              "${pkgs.television}/bin/tv update-channels"
            ];

            Type = "oneshot";
          };

          Unit.Description = "Update tldr pages and television channels";
        };

        systemd.user.timers.update-cli-caches = {
          Install.WantedBy = [ "timers.target" ];

          Timer = {
            OnCalendar = "weekly";
            Persistent = true;
            RandomizedDelaySec = "1h";
          };

          Unit.Description = "Weekly tldr/television cache update";
        };

        xdg.configFile =
          builtins.listToAttrs (
            map
              (name: {
                name = "television/cable/${name}";
                value.source = config.lib.dots.link "television/cable/${name}";
              })
              [
                "apps.toml"
                "channels.toml"
                "flake-inputs.toml"
                "hypr-clients.toml"
                "herdr-sesh.toml"
                "herdr-sessions.toml"
                "hypr-workspaces.toml"
                "mdless.toml"
                "mdpick.toml"
                "media-players.toml"
                "nix-generations.toml"
                "nix-options.toml"
                "nix-pkgs.toml"
                "nix.toml"
                "sessions.toml"
                "tmux-sessions.toml"
                "tuios-sessions.toml"
                "zellij-sessions.toml"
                "zsh-history.toml"
                "update-pkgs.toml"
                "cheatsheets.toml"
                "keybinds.toml"
              ]
          )
          // {
            "television/config.toml".source = config.lib.dots.link "television/config.toml";

            "television/themes/catppuccin-mocha-mauve.toml".source =
              config.lib.dots.link "television/themes/catppuccin-mocha-mauve.toml";

            "television/tv-slim.toml".source = config.lib.dots.link "television/tv-slim.toml";
          };

        xdg.desktopEntries.tv-channels = {
          settings = {
            StartupNotify = "true";
          };

          categories = [
            "Utility"
            "System"
            "ConsoleOnly"
          ];

          comment = "Browse and launch Television channels in a floating terminal";
          exec = "ghostty --class=com.ghostty.float -e tv";
          genericName = "Television Fuzzy Finder Channels";
          icon = "utilities-terminal";
          name = "TV Channels";
          terminal = false;
          type = "Application";
        };
      };

    persistHome.directories = [
      ".local/share/television"
    ];
  };
}
