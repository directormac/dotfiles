# Collie (`collie`)

Self-hosted mobile client PWA for terminal AI coding agents (Pi, OMP, Antigravity, OpenCode) running inside Herdr, accessible locally over Wi-Fi/LAN and remotely over Tailscale.

## Overview

Collie provides a web-based Progressive Web App (PWA) to monitor, inspect, and reply to agent loops and terminal multiplexer sessions directly from mobile devices. It runs as a local bridge daemon and connects natively to the Herdr multiplexer (`COLLIE_MUX=herdr`), which manages agent tabs and panes.

### Key Architecture Features

1. **Unified Multiplexer Architecture**: Drives Herdr directly as the single source of truth for all terminal agent workspaces and sessions, removing brittle dual-instance splits.
2. **Multi-Agent Deep Integration**:
   - **Pi** (`pi`): Full chat view, prompt cache countdown, journal reading (`~/.pi/agent/sessions`), and walky-talky messaging.
   - **Oh My Pi** (`omp`): Full chat view, session tree inspection (`/tree`), compact/resume commands, journal reading (`~/.omp/agent/sessions`), and queue key handling (`ctrl+q`).
   - **Antigravity** (`agy` / `antigravity-cli`): Native surface hold profile, status slash commands, and walky-talky skill integration (`~/.gemini/GEMINI.md`).
   - **OpenCode** (`opencode`): Native state sync, compaction detection, and session log parsing.
3. **Local Wi-Fi & Tailscale Networking**:
   - Listens on `0.0.0.0:8787` (`allow_non_loopback_bind = true`, `allow_any_host = true`) for direct phone access over local Wi-Fi / LAN (`http://<lan-ip>:8787`).
   - Seamlessly published over Tailscale Serve HTTPS (`https://<tailscale-node>:443` -> `http://127.0.0.1:8787`) for encrypted, authenticated remote access.
4. **Local Voxtype Speech-to-Text (STT)**:
   - Hooked to Collie's `local-cli` STT provider via `collie-voxtype-stt`.
   - Converts browser-recorded Opus/WebM and AAC/MP4 audio into 16kHz mono WAV via `ffmpeg`.
   - Includes silence threshold detection to eliminate Whisper silence hallucinations and provide instant response (<100ms) on silent probe clips.
   - Transcribes zero-egress speech on-device with `voxtype` whisper inference.
5. **Walky-Talky Agent Collaboration**:
   - Inter-agent message bus allowing `pi`, `omp`, and `antigravity` to message each other or receive operator instructions from the phone.
6. **Catppuccin Mocha UI & Custom Themes**:
   - Version 2 theme profile (`config/collie/themes/catppuccin-mocha.collie-theme.json`) matching dotfiles aesthetic with full 18-color ANSI terminal palette.

---

## Nix Integration & File Layout

- **Aspect Definition**: `modules/aspects/applications/dev/ai/collie.nix`
- **Role Inclusion**: `modules/aspects/roles/dev.nix` (`dev.ai.collie`)
- **Package**: `pkgs/by-name/collie/package.nix` (`v1.24.0-edge.4+c6a690d`)
- **STT Helper**: `collie-voxtype-stt` (built via Nix, symlinked to `~/.local/bin/collie-voxtype-stt`)
- **Dotfiles Out-of-Store Config**:
  - `config/collie/config.toml` -> Linked to `~/.collie/config.toml` and `~/.config/herdr/plugins/config/herdr.collie/config.toml`
  - `config/collie/commands.toml` -> Custom slash commands on mobile action bar (`/tree`, `/compact`, `/resume`, `/status`)
  - `config/collie/keys.toml` -> Key shortcuts (`ctrl+q`, `ctrl+c`, `Escape`, `Enter`)
  - `config/collie/quick-replies.toml` -> Contextual quick-reply buttons
  - `config/collie/launchers.toml` -> Agent launcher presets (`omp`, `pi`, `agy`, `htop`)
  - `config/collie/themes/` -> Custom themes (`catppuccin-mocha.collie-theme.json`)
- **State & Persistence**:
  - `~/.config/collie`
  - `~/.local/state/collie`
  - `~/.collie`

---

## Configuration Reference

### Bridge & Network (`config/collie/config.toml`)

```toml
[bridge]
poll_ms = 1500
poll_idle_ms = 12000
notify_delay_ms = 30000
read_lines = 200
submit_keys = ["Enter"]
multi_session = true
surface_shadow = false
send_protocol = true
walky = true
transcript = true

[network]
port = 8787
host = "0.0.0.0"
allow_non_loopback_bind = true
allow_any_host = true

[mux]
mux = "herdr"

[access]
redact = true
sent = "on"

[push]
cache_warn_seconds = 300
vapid_subject = "mailto:artifex@local"

[uploads]
max_upload_mb = 25
upload_extra_types = ["nix", "diff", "patch", "kdl", "log"]

[update]
update_repo = "AltanS/collie"
keep_versions = 2
skill_sync = true

[serve]
skip_serve = false
serve_mode = "https"
serve_port = 443

[stt]
stt_provider = "local-cli"
stt_command = "/home/artifex/.local/bin/collie-voxtype-stt"
```

---

## CLI Usage

### Service Management

```bash
# Check status and listening URLs
collie status

# Start bridge daemon and publish Tailscale front door
collie start

# Restart bridge daemon
collie restart

# Stop bridge daemon
collie stop

# Live journal logs
collie logs
```

### Pairing Devices

```bash
# Generate one-time pairing QR / code for phone
collie pair

# List currently paired devices
collie devices
```

### Voice & Speech-to-Text (Voxtype)

```bash
# Check STT provider status
collie stt status

# Verify transcription pipeline (sends wav, webm, mp4 probes)
collie stt test
```

### Walky-Talky (Agent Messaging)

```bash
# List reachable agent panes and their states
collie walky who

# Send message to an agent pane
collie walky send local/w1:p4#mj39 "Tests are green. Ready for review."

# Read incoming unread messages in the current pane
collie walky inbox

# Reply to a message
collie walky reply wt_k3f9x2m8q1a0 "Acknowledged."

# Check status of sent message
collie walky status wt_k3f9x2m8q1a0

# Sync walky-talky skills into agent instruction files
collie skill sync
```

### Diagnostics

```bash
# Validate full installation, permissions, multiplexer socket, and integrations
collie doctor

# Check configuration syntax and show active values
collie config check
collie config show
```

---

## Mobile Access & Connectivity

1. **Local Wi-Fi / LAN**:
   - Open browser on mobile phone connected to the same local Wi-Fi.
   - Navigate to `http://<machine-ip>:8787` (e.g. `http://192.168.123.42:8787`).
   - If not yet paired, enter the code from `collie pair`.
2. **Tailscale Remote Access**:
   - Ensure phone is connected to Tailscale VPN.
   - Navigate to `https://super.tail01fba8.ts.net/`.
3. **PWA Installation**:
   - Tap browser menu -> **Add to Home screen** / **Install App** for full-screen PWA mode.

---

## Troubleshooting

### 1. Banner shows `Collie isn't answering on :8787 yet`
- Check service status: `systemctl --user status collie`.
- Check logs: `collie logs` or `journalctl --user -u collie -f`.
- Verify port 8787 is not bound by an orphaned process: `ss -tulpn | grep 8787`.

### 2. Page loads but stays blank or 403 `cross-origin rejected`
- Cause: Host validation rejected request from an unexpected IP or domain.
- Fix: Ensure `allow_any_host = true` and `allow_non_loopback_bind = true` in `config/collie/config.toml`, then `collie restart`.

### 3. Agent pane shows raw terminal instead of Chat view
- Chat view requires the agent to report its session through Herdr.
- Check integration status: `herdr integration status`.
- If an agent is missing or outdated:
  - Run `herdr integration install <agent>` (e.g. `herdr integration install omp` or `pi`).
  - Restart the agent inside that pane so it loads the hook.
- Run `collie doctor` to verify `agent-sessions` and `journal-roots`.

### 4. Walky-Talky: `run this inside a pane, or send from the phone`
- Walky-talky `send` commands determine the sender identity from the terminal pane environment.
- Run `collie walky who` inside the agent pane (marked with `(you)`).
- Outside terminal panes, send messages using the Collie mobile UI composer (**Send as message**).

### 5. STT: `collie stt test` failures
- Ensure `collie-voxtype-stt` is executable: `chmod +x ~/.local/bin/collie-voxtype-stt`.
- Verify `ffmpeg` and `voxtype` are accessible in PATH: `which ffmpeg && which voxtype`.
- Run a manual probe:
  ```bash
  collie stt test
  ```
  All three audio containers (wav, webm, mp4) should report `✓` with empty transcript on silence.
