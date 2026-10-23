# Collie (`collie`)

Self-hosted mobile client PWA for terminal AI coding agents (Herdr, tmux, zellij) served securely over Tailscale.

## Overview

Collie provides a web-based Progressive Web App (PWA) to monitor, inspect, and reply to agent loops and terminal multiplexer sessions from mobile devices. It runs as a local bridge daemon and connects to terminal multiplexers via Unix domain sockets or CLI adapters.

In this configuration, Collie supports **dual isolated instances**:
1. **Herdr Instance** (default) running on port `8787` for Herdr agent sessions.
2. **Tmux Instance** running on port `8788` for standard tmux sessions.

## Package Architecture & Nix Integration

- **Package Definition**: `pkgs/by-name/collie/package.nix`
- **Aspect Integration**:
  - `modules/aspects/applications/dev/mux/herdr.nix` (Herdr integration)
  - `modules/aspects/applications/dev/mux/tmux.nix` (Tmux integration & persistence)
- **Overlay**: `pkgs/overlays.nix` ensures `final.collie` resolves to the local standalone prebuilt binary (`v1.23.3`), avoiding unpackaged wrapper failures from external flake inputs.
- **Persistence (`persistHome`)**:
  - `~/.config/collie`
  - `~/.local/state/collie` (primary Herdr state)
  - `~/.config/herdr/plugins/config/herdr.collie-tmux` (tmux instance configuration)
  - `~/.local/state/collie-tmux` (tmux instance state)

## Multi-Instance Configuration

Collie resolves its active instance from the `COLLIE_INSTANCE` environment variable. When `COLLIE_INSTANCE` is set, Collie requires an explicit `COLLIE_PORT` and uses an instance-specific configuration directory and state directory.

### Instance Comparison

| Attribute | Primary Herdr Instance (`collie-herdr`) | Secondary Tmux Instance (`collie-tmux`) |
| :--- | :--- | :--- |
| **`COLLIE_INSTANCE`** | _unset_ (default) | `tmux` |
| **`COLLIE_MUX`** | `herdr` | `tmux` |
| **`COLLIE_PORT`** | `8787` | `8788` |
| **Config Directory** | `~/.config/herdr/plugins/config/herdr.collie` | `~/.config/herdr/plugins/config/herdr.collie-tmux` |
| **State Directory** | `~/.local/state/collie` | `~/.local/state/collie-tmux` |
| **Systemd Unit** | `collie.service` | `collie-tmux.service` |
| **Shell Command** | `collie` or `collie-herdr` | `collie-tmux` |

### Configuration Files (`.env`)

#### Herdr Instance (`~/.config/herdr/plugins/config/herdr.collie/.env`)
```bash
COLLIE_MUX=herdr
```

#### Tmux Instance (`~/.config/herdr/plugins/config/herdr.collie-tmux/.env`)
```bash
COLLIE_INSTANCE=tmux
COLLIE_MUX=tmux
COLLIE_PORT=8788
COLLIE_STATE_DIR=/home/artifex/.local/state/collie-tmux
```

## CLI Usage & Commands

Prepend `collie-tmux` for tmux operations, or use `collie` / `collie-herdr` for Herdr operations.

### Service Management

```bash
# Start bridge daemon and publish front-door
collie-tmux start
collie-herdr start

# Stop bridge daemon
collie-tmux stop
collie-herdr stop

# Restart bridge daemon
collie-tmux restart
collie-herdr restart

# Check runtime status and listening ports
collie-tmux status
collie-herdr status

# Tail service logs (systemd journal)
collie-tmux logs
collie-herdr logs
```

### Pairing Mobile Devices

Each instance maintains its own paired devices in its respective state directory:

```bash
# Generate one-time pairing code and QR for phone
collie-tmux pair
collie-herdr pair

# List paired devices
collie-tmux devices
collie-herdr devices
```

### Tailscale Serve & Networking

- The primary instance serves at the Tailscale root `https://<tailscale-host>/` proxying to `http://127.0.0.1:8787`.
- The tmux instance operates at `http://127.0.0.1:8788`. To publish it via Tailscale serve:
  ```bash
  COLLIE_BASE_PATH=/tmux collie-tmux serve
  ```

### Diagnostics

```bash
# Validate installation, permissions, multiplexer socket, and front-door
collie-tmux doctor
collie-herdr doctor
```

## Troubleshooting

### Environment Variable Shadowed (`note: COLLIE_MUX=... shadowed by .env`)
Collie prioritizes values in `<configDir>/.env` over ambient shell variables. Always use `COLLIE_INSTANCE=tmux` (or the `collie-tmux` alias), which targets the isolated `herdr.collie-tmux` config directory where `COLLIE_MUX=tmux` is declared.

### Binary Missing (`error: no collie binary at ...`)
Ensure `pkgs/overlays.nix` points to `pkgs/by-name/collie/package.nix` (precompiled binary release v1.23.3+) rather than source-only derivations.
