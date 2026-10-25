# Reusable cheatsheet updater for DankMaterialShell (DMS).
# Parses and extracts keybindings from application configurations (Yazi, Herdr, etc.)
# and verifies/formats all cheatsheets in config/DankMaterialShell/cheatsheets/*.json.
#
#   update-cheatsheets               # update & format all cheatsheets
#   update-cheatsheets yazi herdr    # update only specific targets
#   update-cheatsheets --check       # validate syntax and schema of all cheatsheets
#   update-cheatsheets --list        # list all registered cheatsheet providers
{
  coreutils,
  git,
  jq,
  python3,
  writeShellApplication,
}:
writeShellApplication {
  name = "update-cheatsheets";

  runtimeInputs = [
    coreutils
    git
    jq
    python3
  ];

  text = ''
    REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/.dotfiles")"
    CHEATSHEETS_DIR="$REPO_ROOT/config/DankMaterialShell/cheatsheets"

    if [[ ! -d "$CHEATSHEETS_DIR" ]]; then
      echo "Error: Cheatsheets directory not found at $CHEATSHEETS_DIR" >&2
      exit 1
    fi

    python3 - "$REPO_ROOT" "$CHEATSHEETS_DIR" "$@" <<'EOF'
    import json
    import os
    import sys
    import tomllib
    from pathlib import Path

    repo_root = Path(sys.argv[1])
    cheatsheets_dir = Path(sys.argv[2])
    args = sys.argv[3:]

    check_only = "--check" in args
    list_only = "--list" in args
    targets = [a for a in args if not a.startswith("-")]

    def load_json(path):
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)

    def write_json(path, data):
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
            f.write("\n")

    def update_yazi():
        keymap_path = repo_root / "config/yazi/keymap.toml"
        out_path = cheatsheets_dir / "yazi.json"
        if not keymap_path.exists():
            return False, "config/yazi/keymap.toml not found"

        with open(keymap_path, "rb") as f:
            data = tomllib.load(f)

        existing = load_json(out_path) if out_path.exists() else {
            "title": "Yazi Keybinds",
            "provider": "yazi",
            "binds": {}
        }

        # Categories mapping
        categories = {
            "Navigation": [],
            "Bookmarks": [],
            "Sudo Operations": [],
            "Clipboard & Archives": [],
            "Git & Projects": [],
            "Tabs & Dual Pane": [],
            "Panes & Layout": []
        }

        # Preserve standard navigation
        nav_defaults = [
            { "key": "h / l", "desc": "Leave to parent / Enter child directory" },
            { "key": "j / k", "desc": "Next / Previous file" },
            { "key": "H / L", "desc": "Back / Forward in directory history" },
            { "key": "gg / G", "desc": "Go to top / bottom of file list" },
            { "key": "<Space>", "desc": "Toggle selection state & move down" },
            { "key": "v / V", "desc": "Enter visual mode / visual unset mode" },
            { "key": "o / <Enter>", "desc": "Open selected files" },
            { "key": "O", "desc": "Open selected files interactively (picker)" },
            { "key": "s / S", "desc": "Search by name (fd) / content (ripgrep)" },
            { "key": "z / Z", "desc": "Jump via fzf / zoxide" },
            { "key": "f / /", "desc": "Filter files / Find in current directory" }
        ]
        categories["Navigation"] = nav_defaults

        for item in data.get("mgr", {}).get("prepend_keymap", []):
            raw_on = item.get("on")
            key_str = " ".join(raw_on) if isinstance(raw_on, list) else str(raw_on)
            desc = item.get("desc", "")
            run = str(item.get("run", ""))

            entry = { "key": key_str, "desc": desc }

            if "whoosh" in run:
                entry["subcat"] = "Whoosh"
                categories["Bookmarks"].append(entry)
            elif "sudo" in run:
                entry["subcat"] = "Root"
                categories["Sudo Operations"].append(entry)
            elif "compress" in run or "ouch" in run:
                entry["subcat"] = "Archive"
                categories["Clipboard & Archives"].append(entry)
            elif "wl-clipboard" in run or "copy" in run:
                entry["subcat"] = "Clipboard"
                categories["Clipboard & Archives"].append(entry)
            elif "kdeconnect" in run:
                entry["subcat"] = "Share"
                categories["Clipboard & Archives"].append(entry)
            elif "lazygit" in run or "git" in run:
                entry["subcat"] = "Git"
                categories["Git & Projects"].append(entry)
            elif "trash" in run:
                entry["subcat"] = "Trash"
                categories["Git & Projects"].append(entry)
            elif "projects" in run:
                entry["subcat"] = "Projects"
                categories["Git & Projects"].append(entry)
            elif "mount" in run or "gvfs" in run:
                entry["subcat"] = "Mount"
                categories["Git & Projects"].append(entry)
            elif "split-tabs" in run:
                entry["subcat"] = "Split"
                categories["Tabs & Dual Pane"].append(entry)
            elif "close-and-restore-tab" in run or "close" in run:
                entry["subcat"] = "Tabs"
                categories["Tabs & Dual Pane"].append(entry)
            elif "toggle-pane" in run:
                entry["subcat"] = "Layout"
                categories["Panes & Layout"].append(entry)
            else:
                categories["Panes & Layout"].append(entry)

        # Tabs extras
        categories["Tabs & Dual Pane"].extend([
            { "key": "t", "desc": "Create a new tab with CWD", "subcat": "Tabs" },
            { "key": "[ / ]", "desc": "Switch to previous / next tab", "subcat": "Tabs" },
            { "key": "1..9", "desc": "Switch directly to tab 1 through 9", "subcat": "Tabs" }
        ])
        categories["Panes & Layout"].append(
            { "key": "J / K", "desc": "Scroll down / up inside file preview pane", "subcat": "Preview" }
        )

        existing["binds"] = {k: v for k, v in categories.items() if v}
        write_json(out_path, existing)
        return True, f"updated {out_path.name} from keymap.toml"

    def update_herdr():
        config_path = repo_root / "config/herdr/config.toml"
        out_path = cheatsheets_dir / "herdr.json"
        if not config_path.exists():
            return False, "config/herdr/config.toml not found"

        with open(config_path, "rb") as f:
            data = tomllib.load(f)

        keys = data.get("keys", {})
        commands = keys.get("command", [])

        binds = {
            "Prefix": [{ "key": keys.get("prefix", "ctrl+a").replace("ctrl+", "Ctrl+").upper(), "desc": "Primary prefix key" }],
            "Popups & Overlays": [],
            "Panes": [],
            "Tabs": [],
            "Workspaces": [],
            "General": []
        }

        for cmd in commands:
            k = cmd.get("key")
            k_str = " | ".join(k) if isinstance(k, list) else str(k)
            k_str = k_str.replace("prefix+", "Ctrl+A, ").replace("shift+", "Shift+").replace("alt+", "Alt+").replace("ctrl+", "Ctrl+")
            d = cmd.get("description", "")
            binds["Popups & Overlays"].append({ "key": k_str, "desc": d, "subcat": "Popups" })

        # Populate core actions from keys
        action_map = [
            ("split_vertical", "Split pane vertically", "Panes", "Split"),
            ("split_horizontal", "Split pane horizontally", "Panes", "Split"),
            ("close_pane", "Close active pane", "Panes", "Management"),
            ("focus_pane_left", "Focus pane left", "Panes", "Navigation"),
            ("focus_pane_down", "Focus pane down", "Panes", "Navigation"),
            ("focus_pane_up", "Focus pane up", "Panes", "Navigation"),
            ("focus_pane_right", "Focus pane right", "Panes", "Navigation"),
            ("swap_pane_left", "Swap pane left", "Panes", "Management"),
            ("cycle_pane_next", "Cycle pane focus forward", "Panes", "Navigation"),
            ("zoom", "Toggle pane zoom (fullscreen)", "Panes", "Layout"),
            ("new_tab", "Create a new tab", "Tabs", "Tabs"),
            ("close_tab", "Close active tab", "Tabs", "Tabs"),
            ("rename_tab", "Rename active tab", "Tabs", "Tabs"),
            ("previous_tab", "Previous tab", "Tabs", "Tabs"),
            ("next_tab", "Next tab", "Tabs", "Tabs"),
            ("switch_tab", "Direct jump to tab 1..9", "Tabs", "Tabs"),
            ("new_workspace", "Create new workspace", "Workspaces", "Workspaces"),
            ("new_worktree", "Create new git worktree workspace", "Workspaces", "Workspaces"),
            ("previous_workspace", "Previous workspace", "Workspaces", "Workspaces"),
            ("next_workspace", "Next workspace", "Workspaces", "Workspaces"),
            ("toggle_sidebar", "Toggle sidebar visibility", "General", "UI"),
            ("copy_mode", "Enter scrollback copy mode", "General", "Buffer"),
            ("detach", "Detach from Herdr server", "General", "Session"),
            ("reload_config", "Hot-reload configuration", "General", "Config"),
            ("settings", "Open interactive settings", "General", "Config"),
            ("help", "Show keyboard shortcuts help", "General", "Help"),
        ]

        for key_name, desc, cat, subcat in action_map:
            val = keys.get(key_name)
            if val:
                val_str = " | ".join(val) if isinstance(val, list) else str(val)
                val_str = val_str.replace("prefix+", "Ctrl+A, ").replace("shift+", "Shift+").replace("alt+", "Alt+").replace("ctrl+", "Ctrl+")
                binds[cat].append({ "key": val_str, "desc": desc, "subcat": subcat })

        existing = load_json(out_path) if out_path.exists() else { "title": "Herdr Keybinds", "provider": "herdr" }
        existing["binds"] = binds
        write_json(out_path, existing)
        return True, f"updated {out_path.name} from config.toml"
    def update_zsh():
        out_path = cheatsheets_dir / "zsh.json"
        existing = load_json(out_path) if out_path.exists() else { "title": "Zsh Keybinds", "provider": "zsh" }

        binds = {
            "Autosuggest & History": [
                { "key": "Ctrl+Y / Ctrl+Tab", "desc": "Accept autosuggestion", "subcat": "Autosuggest" },
                { "key": "Ctrl+Space", "desc": "Accept and immediately execute autosuggestion", "subcat": "Autosuggest" },
                { "key": "Ctrl+R", "desc": "Interactive SQLite history search (histdb-fzf)", "subcat": "History" },
                { "key": "Ctrl+Alt+R", "desc": "Interactive SQLite history search (histdb-skim)", "subcat": "History" },
                { "key": "Ctrl+Shift+R", "desc": "Television Slim history search", "subcat": "History" },
                { "key": "Up / Down", "desc": "Prefix history navigation", "subcat": "History" }
            ],
            "Navigation & Fuzzy Search": [
                { "key": "Tab", "desc": "Fuzzy completion menu (fzf-tab)", "subcat": "Completion" },
                { "key": "< / >", "desc": "Switch completion group in fzf-tab", "subcat": "Completion" },
                { "key": "Ctrl+O", "desc": "Super search (files, dirs, git) via fzf", "subcat": "Search" },
                { "key": "Ctrl+H", "desc": "Interactive fuzzy manpage & cheat.sh viewer", "subcat": "Docs" }
            ],
            "Vi Mode & Line Editing": [
                { "key": "Escape / Ctrl+[", "desc": "Switch to vi command mode (vicmd)", "subcat": "Mode" },
                { "key": "i / a", "desc": "Enter vi insert mode before / after cursor", "subcat": "Mode" },
                { "key": "v / vv (vicmd)", "desc": "Edit command line in $EDITOR (Neovim)", "subcat": "Editor" },
                { "key": "cs / ds / ys", "desc": "Vim surround: change, delete, add surrounding quotes/brackets", "subcat": "Surround" },
                { "key": "gp / gP", "desc": "Paste from system clipboard (wl-copy) after / before cursor", "subcat": "Clipboard" },
                { "key": "gx", "desc": "Open URL or path under cursor", "subcat": "Navigation" },
                { "key": "Ctrl+W", "desc": "Delete backward word", "subcat": "Editing" },
                { "key": "Ctrl+U", "desc": "Kill entire command line before cursor", "subcat": "Editing" },
                { "key": "Ctrl+K", "desc": "Kill entire command line after cursor", "subcat": "Editing" },
                { "key": "Ctrl+A / Ctrl+E", "desc": "Jump to beginning / end of line buffer", "subcat": "Navigation" },
                { "key": "Ctrl+_", "desc": "Undo last edit", "subcat": "Undo" },
                { "key": "Ctrl+L", "desc": "Clear terminal screen and redraw prompt", "subcat": "Screen" }
            ]
        }

        existing["binds"] = binds
        write_json(out_path, existing)
        return True, f"updated {out_path.name}"


    all_files = sorted(cheatsheets_dir.glob("*.json"))

    if list_only:
        print(f"Registered DMS Cheatsheets ({len(all_files)} total):")
        for f in all_files:
            try:
                data = load_json(f)
                title = data.get("title", f.stem)
                provider = data.get("provider", f.stem)
                b = data.get("binds", {})
                total = sum(len(v) for v in b.values())
                print(f"  • {provider:<10} - {title:<20} ({len(b)} categories, {total} keybinds)")
            except Exception as e:
                print(f"  ! {f.name}: error reading ({e})")
        sys.exit(0)

    if check_only:
        errs = 0
        print("Checking cheatsheet JSON files...")
        for f in all_files:
            try:
                d = load_json(f)
                assert "title" in d, "missing title"
                assert "provider" in d, "missing provider"
                assert "binds" in d and isinstance(d["binds"], dict), "missing/invalid binds"
                for cat, binds in d["binds"].items():
                    for item in binds:
                        assert "key" in item and "desc" in item, f"malformed bind in {cat}: {item}"
                print(f"  ✓ {f.name}: valid")
            except Exception as e:
                print(f"  ✗ {f.name}: {e}")
                errs += 1
        sys.exit(1 if errs > 0 else 0)

    # Update mode
    if not targets or "yazi" in targets:
        ok, msg = update_yazi()
        print(f"{'✓' if ok else '✗'} yazi: {msg}")

    if not targets or "herdr" in targets:
        ok, msg = update_herdr()
        print(f"{'✓' if ok else '✗'} herdr: {msg}")

    if not targets or "zsh" in targets:
        ok, msg = update_zsh()
        print(f"{'✓' if ok else '✗'} zsh: {msg}")

    # Format all remaining files
    for f in all_files:
        try:
            d = load_json(f)
            write_json(f, d)
            print(f"✓ formatted {f.name}")
        except Exception as e:
            print(f"✗ error formatting {f.name}: {e}")
    EOF
  '';

  meta.description = "Validate, extract, and update DMS cheatsheets from dotfiles configs";
}
