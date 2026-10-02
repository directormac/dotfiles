{ inputs, self, ... }: {

  # Reference https://mangowm.github.io/docs/nix-options
  flake.homeModules.mangowm = { config, pkgs, ... }:
    let
      mango-noctalia-notifier = pkgs.writers.writePython3Bin "mango-noctalia-notifier" { } ''
        import json
        import shutil
        import signal
        import subprocess
        import time

        LAYOUT_NAMES = {
            "T": "Tile",
            "S": "Scroller",
            "G": "Grid",
            "M": "Monocle",
            "K": "Deck",
            "CT": "Center Tile",
            "RT": "Right Tile",
            "VS": "Vertical Scroller",
            "VT": "Vertical Tile",
            "VG": "Vertical Grid",
            "VK": "Vertical Deck",
            "DW": "Dwindle",
            "F": "Fair",
            "VF": "Vertical Fair",
        }

        ID_WORKSPACE = 8810
        ID_LAYOUT = 8811
        ID_WINDOW = 8812

        running = True


        def handle_signal(sig, frame):
            global running
            running = False


        signal.signal(signal.SIGINT, handle_signal)
        signal.signal(signal.SIGTERM, handle_signal)


        def notify(
            summary: str,
            body: str,
            replace_id: int,
            icon: str = "",
            timeout: int = 1200
        ):
            if shutil.which("notify-send"):
                cmd = [
                    "notify-send",
                    "-a", "Mango WM",
                    "-r", str(replace_id),
                    "-t", str(timeout),
                    "-u", "low",
                ]
                if icon:
                    cmd.extend(["-i", icon])
                cmd.extend([summary, body])
                try:
                    subprocess.run(
                        cmd,
                        stdout=subprocess.DEVNULL,
                        stderr=subprocess.DEVNULL,
                        check=False,
                    )
                    return
                except Exception:
                    pass

            if shutil.which("noctalia"):
                try:
                    subprocess.run(
                        ["noctalia", "msg", "notification-show", summary, body],
                        stdout=subprocess.DEVNULL,
                        stderr=subprocess.DEVNULL,
                        check=False,
                    )
                except Exception:
                    pass


        class MonitorState:
            def __init__(
                self,
                name: str,
                active: bool,
                layout_symbol: str,
                active_tags: set,
                tag_counts: dict
            ):
                self.name = name
                self.active = active
                self.layout_symbol = layout_symbol
                self.active_tags = active_tags
                self.tag_counts = tag_counts


        def parse_monitors(data: dict) -> dict:
            states = {}
            for m in data.get("monitors", []):
                name = m.get("name", "unknown")
                active = m.get("active", False)
                layout_symbol = m.get("layout_symbol", "")
                active_tags = set(m.get("active_tags", []))
                tag_counts = {}
                for t in m.get("tags", []):
                    tag_counts[t.get("index")] = t.get("client_count", 0)
                states[name] = MonitorState(
                    name, active, layout_symbol, active_tags, tag_counts
                )
            return states


        def run_loop():
            while running:
                try:
                    proc = subprocess.Popen(
                        ["mmsg", "watch", "all-monitors"],
                        stdout=subprocess.PIPE,
                        text=True,
                        bufsize=1,
                    )
                except Exception:
                    time.sleep(2)
                    continue

                prev_states = None
                try:
                    for line in proc.stdout:
                        if not running:
                            break
                        line = line.strip()
                        if not line:
                            continue
                        try:
                            data = json.loads(line)
                        except Exception:
                            continue

                        curr_states = parse_monitors(data)
                        if prev_states is None:
                            prev_states = curr_states
                            continue

                        num_monitors = len(curr_states)
                        for name, curr_m in curr_states.items():
                            prev_m = prev_states.get(name)
                            if not prev_m:
                                continue

                            mon_sfx = f" • {name}" if num_monitors > 1 else ""

                            # 1. Detect layout change on active monitor
                            if (
                                curr_m.active
                                and prev_m.layout_symbol != curr_m.layout_symbol
                            ):
                                sym = curr_m.layout_symbol
                                layout_name = LAYOUT_NAMES.get(sym, sym)
                                notify(
                                    "Layout",
                                    f"{layout_name} ({sym}){mon_sfx}",
                                    ID_LAYOUT,
                                    icon="preferences-desktop-display",
                                )

                            # 2. Detect workspace change
                            if prev_m.active_tags != curr_m.active_tags:
                                tags = sorted(curr_m.active_tags)
                                tags_str = ", ".join(str(t) for t in tags)
                                notify(
                                    "Workspace",
                                    f"Workspace {tags_str}{mon_sfx}",
                                    ID_WORKSPACE,
                                    icon="preferences-desktop-workspaces",
                                )
                            else:
                                # 3. Detect silent window move between tags
                                prev_tot = sum(prev_m.tag_counts.values())
                                curr_tot = sum(curr_m.tag_counts.values())
                                if (
                                    prev_tot == curr_tot
                                    and prev_m.tag_counts != curr_m.tag_counts
                                ):
                                    dec = [
                                        t for t, c in curr_m.tag_counts.items()
                                        if c < prev_m.tag_counts.get(t, 0)
                                    ]
                                    inc = [
                                        t for t, c in curr_m.tag_counts.items()
                                        if c > prev_m.tag_counts.get(t, 0)
                                    ]
                                    if len(dec) == 1 and len(inc) == 1:
                                        msg = f"Moved to Workspace {inc[0]}"
                                        notify(
                                            "Window Moved",
                                            f"{msg}{mon_sfx}",
                                            ID_WINDOW,
                                            icon="preferences-desktop-workspaces",
                                        )

                        prev_states = curr_states
                except Exception:
                    pass
                finally:
                    try:
                        proc.terminate()
                        proc.wait(timeout=1)
                    except Exception:
                        pass
                    if running:
                        time.sleep(1)


        if __name__ == "__main__":
            run_loop()
      '';
    in
    {

    wayland.windowManager.mango = {
      enable = true;
      systemd = {
        enable = true;
        xdgAutostart = true;
        variables = [
          "--all"
        ];
        extraCommands = [
          "systemctl --user reset-failed"
          "systemctl --user start mango-session.target"
        ];
      };
      autostart_sh =
        # sh
        ''
          noctalia &
          mango-noctalia-notifier &
          systemctl --user restart xdg-desktop-portal xdg-desktop-portal-wlr &
          wl-clip-persist --clipboard regular --reconnect-tries 0 &
          wl-paste --type text --watch cliphist store &
        '';
      extraConfig = ''
        source = ${config.home.homeDirectory}/.dotfiles/config/mango/config.conf
      '';
    };

    xdg.configFile."television/cable/mango-clients.toml".text =
      # toml
      ''
        [metadata]
        name = "mango-clients"
        description = "Manage active window manager clients with a detailed preview"

        [source]
        # Line format: ID │ APPID │ TITLE
        command = "mmsg get all-clients | jq -r '.clients[] | \"\\(.id) │ \\(.appid) │ \\(.title)\"'"

        [preview]
        # We use jq to match the current line's window ID back against the full state,
        # and then print out an itemized list of key-value properties.
        command = "WINDOW_ID=$(echo '{}' | cut -d'│' -f1 | tr -d ' '); mmsg get all-clients | jq -r --arg id \"$WINDOW_ID\" '.clients[] | select(.id == $id) | \"🆔 Window ID:   \\(.id)\\n🚀 Application: \\(.appid)\\n📋 Window Title: \\(.title)\\n📌 Workspace:    \\(.workspace // \"N/A\")\\n🔍 Floating:     \\(.is_floating // \"false\")\\n✨ Fullscreen:   \\(.is_fullscreen // \"false\")\"'"

        [keybindings]
        enter = "actions:focus"
        ctrl-y = "actions:copy_info"
        ctrl-x = "actions:kill_client"

        [actions.focus]
        command = "mmsg dispatch focus_window $(echo '{}' | cut -d'│' -f1 | tr -d ' ')"
        mode = "execute"

        [actions.copy_info]
        command = "echo '{}' | cut -d'│' -f2,3 | tr -d ' ' | wl-copy"
        mode = "execute"

        [actions.kill_client]
        command = "mmsg dispatch close_window $(echo '{}' | cut -d'│' -f1 | tr -d ' ')"
        mode = "execute"      '';

    xdg.configFile."xdg-desktop-portal-wlr/config".text = ''
      [screencast]
      max_fps=60
      chooser_type=simple
      chooser_cmd=${pkgs.slurp}/bin/slurp -f 'Monitor: %o' -or
    '';

    xdg.configFile."xdg-desktop-portal-wlr/mango".text = ''
      [screencast]
      max_fps=60
      chooser_type=simple
      chooser_cmd=${pkgs.slurp}/bin/slurp -f 'Monitor: %o' -or
    '';

    home.packages = with pkgs; [
      slurp
      wl-clipboard
      libnotify
      mango-noctalia-notifier
    ];

    systemd.user.services.mango-noctalia-notifier = {
      Unit = {
        Description = "Mango WM to Noctalia Notification Bridge";
        PartOf = [ "mango-session.target" ];
        After = [ "mango-session.target" ];
      };
      Service = {
        ExecStart = "${mango-noctalia-notifier}/bin/mango-noctalia-notifier";
        Restart = "always";
        RestartSec = 2;
      };
      Install = {
        WantedBy = [ "mango-session.target" ];
      };
    };

    home.file.".config/mango/config.d" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/mango/config.d";
      recursive = true;
    };

    home.file.".config/mango/dms" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/mango/dms";
      recursive = true;
    };

  };

  flake.nixosModules.mangowm = { config, pkgs, ... }: {
    imports = [
      inputs.mangowm.nixosModules.mango
      self.nixosModules.noctalia
    ];

    home-manager.users.${config.preferences.user.name} = {
      imports = [
        inputs.mangowm.hmModules.mango
        self.homeModules.mangowm
      ];
    };

    programs.mango.enable = true;

    xdg.portal.wlr = {
      enable = true;
      settings = {
        screencast = {
          max_fps = 60;
          chooser_type = "simple";
          chooser_cmd = "${pkgs.slurp}/bin/slurp -f 'Monitor: %o' -or";
        };
      };
    };

    systemd.user.services.xdg-desktop-portal-wlr.path = with pkgs; [
      slurp
    ];

  };
}
