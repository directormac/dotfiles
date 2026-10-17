# Den Dotfiles Configuration

A modern, pure-leaf dendritic NixOS and Home Manager configuration powered by [Den](https://den.denful.dev), [flake-file](https://github.com/denful/flake-file), [devenv](https://devenv.sh), and [agenix-rekey](https://github.com/oddlama/agenix-rekey).

## Quick Links
- [Awesome Nix](https://github.com/nix-community/awesome-nix)
- [Den Documentation](https://den.denful.dev)
- [NixOS Options Search](https://search.nixos.org/options?channel=unstable)
- [Home Manager Options](https://home-manager-options.extranix.com/)
- [devenv Documentation](https://devenv.sh/)
- [flake-parts Documentation](https://flake.parts/)

## Features

- **Dendritic Aspect Architecture**: Pure leaf aspects powered by [Den](https://den.denful.dev), composable roles, and zero-boilerplate automatic discovery.
- **Root Impermanence & Rollback**: Ephemeral Btrfs root subvolume rolled back to clean snapshot on boot with explicit persistence paths under `/persist` and `/cache`.
- **Automated Garbage Collection (`nh`)**: Background weekly system cleanup via `programs.nh.clean` with configurable retention (`--keep-since 4d --keep 3`).
- **Smart Rebuild Switch & Rollback Protection**: `rebuild-switch` labels each generation with `<branch>-<scope>-<rev>-<timestamp>` and automatically rolls back if activation fails so broken configurations never persist.
- **Interactive Generation Management**: `nix-generations` CLI and Television channel (`tv nix-generations`, alias `nhg`) with real-time bootspec metadata, closure diffs, and pruning controls.
- **Television Cable Suite**: Dedicated channels for git worktrees, branches, cliphist, zsh-histdb, systemd units, flake inputs, NixOS options, and packages.
- **Standardized Local Packages**: Custom package suite organized under standard Nix `pkgs/by-name/<pkgname>/package.nix` hierarchy.

## General Workflow & Commands

This repository includes custom tools and scripts in `pkgs/by-name` to streamline daily maintenance and development.

### 1. System Rebuild & Deployment

| Command | Description |
| :--- | :--- |
| `rebuild-switch` *(or `rebuild`)* | Build and activate NixOS with lazygit-style commit label (`<branch>-<scope>-<rev>-<timestamp>`). Automatically reverts and deletes generation on failure. |
| `nh os switch` *(or `nho switch`)* | Standard system switch using `nh`. |
| `nh os test` *(or `nho test`)* | Build and activate system in a transient generation without setting boot default. |
| `nh os build` *(or `nho build`)* | Build system toplevel derivation without activating. |
| `nix-flake-build [host] [--apply]` | Build system configurations with `nix-output-monitor` (`nom`) and optional deployment switch. |

### 2. NixOS Generation Management

| Command | Description |
| :--- | :--- |
| `tv nix-generations` *(or `nhg`, `generations`)* | Fuzzy search, inspect closure diffs, switch, and delete system generations via Television. |
| `nix-generations list` | Print tab-separated table of generations with active indicators and labels. |
| `nix-generations preview <num>` | Detailed bootspec inspection, kernel info, and package closure diff against active system. |
| `nix-generations switch <num>` | Activate and switch to specified generation number. |
| `nix-generations boot <num>` | Set specified generation as bootloader default without immediate activation. |
| `nix-generations delete <num>` | Delete single generation (prevents deleting active generation). |
| `nix-generations delete-older [count/num]` | Prune older generations keeping latest count or strictly older than generation number. |

### 3. Package & Flake Updates

| Command | Description |
| :--- | :--- |
| `nix-flake-update [-e <input>]` | Update flake inputs authenticated via GitHub token, with optional `-e` / `--exclude` flags. |
| `update-pkgs [pkg...]` | Automatically bump versions, hashes, and cargo/vendor dependencies in `pkgs/by-name` via `nix-update`. |
| `nh clean all --keep <count>` | Trigger manual garbage collection keeping the latest N generations. |

### 4. Repository & Codebase Synchronization

| Command | Description |
| :--- | :--- |
| `nix run .#write-flake` | Regenerate `flake.nix` inputs and outputs from `modules/flake-parts/flake-file.nix`. |
| `nix run .#write-files` | Synchronize generated files (`README.md`, `.workmux.yaml`, `.nvim.lua`). |
| `nix run .#write-topology` | Regenerate system topology documentation in `TOPOLOGY.md`. |
| `nix fmt modules/ pkgs/` | Format all Nix modules and packages according to project conventions. |
| `nix flake check --no-build` | Validate all host configurations, checks, packages, and apps. |

## Evaluation Configuration

This repository configures `nixConfig` for strict, safe, and cached builds:

```nix
nixConfig = {
  accept-flake-config = true;
  allow-import-from-derivation = true;
  auto-optimise-store = true;
  lazy-trees = true;
  show-trace = true;
};
```

## Generated Files

The following files in this repository are generated and managed
using [the files flake-parts module](https://github.com/sini/files):

- `README.md`
- `.workmux.yaml`
- `.nvim.lua`

## Automatic Import

Nix files (they're all flake-parts modules) are automatically imported via [import-tree](https://github.com/denful/import-tree).
Nix files prefixed with an underscore are ignored.
No literal path imports are used.
This means files can be moved around and nested in directories freely.

## Architecture

This configuration uses [den](https://github.com/denful/den) for declarative multi-entity system management.

### Entity Model

| Entity | Purpose |
| :--- | :--- |
| `host` | Channel, networking, system configuration, hardware facts |
| `user` | Identity, home directory, Home Manager aspects |

### Aspects

Every feature in [`modules/aspects/`](modules/aspects) is organized as an atomic **leaf aspect** under `den.aspects.*`. Leaf aspects encapsulate their own NixOS, Home Manager, nixpkgs overlay, and impermanence persistence configurations in a single file, and are selectively composed by **roles** (`den.aspects.roles.*`) consumed by hosts:

```text
modules/
├── aspects/
│   ├── applications/
│   │   ├── browsers/        # zen, firefox, librewolf, chromium, tor-browser, _common/
│   │   ├── dev/
│   │   │   ├── ai/          # llm-agents, opencode, pi, antigravity, copilot
│   │   │   ├── editor/      # neovim, helix, vim, lazyvim, doom-emacs, vscode, zed, codium
│   │   │   ├── git/         # git, github, lazygit
│   │   │   ├── lang/        # go, rust, node, elixir, lua, nix, cc, grammars
│   │   │   ├── mux/         # tmux, zellij, sesh, workmux, herdr
│   │   │   ├── networking/  # winbox, wireguard, mtr, doggo
│   │   │   ├── security/    # bitwarden, gpg, ssh, sops
│   │   │   ├── shell/       # direnv, mise, television, starship, zoxide, fzf, bat, btop, vivid, fastfetch
│   │   │   └── tree-sitter/ # grammars
│   │   ├── gaming/          # steam, mangohud, gamescope, gamemode, lutris, heroic, bottles, nix-ld
│   │   ├── media/           # mpv, vlc, rmpd, cava, yt-dlp, imv, feh, mpvpaper
│   │   ├── messaging/       # vesktop
│   │   ├── productivity/    # tuxedo, evince, foliate, galculator, localsend, anydesk, scrcpy
│   │   ├── shell/           # zsh (with histdb), carapace, yazi, superfile, cli-utils
│   │   ├── terminals/       # ghostty, kitty, foot
│   │   └── wayland/         # wl-kbptr, fuzzel, cliphist, quickshell, fcitx5
│   ├── core/                # boot, documentation, locale, mounts, networking, nix, nixpkgs, security, users
│   ├── desktop/             # audio, fonts, greeter, gtk, hyprland, kdeconnect, nautilus, niri, stylix, thunar, udiskie, xdg, xserver
│   ├── hardware/            # bluetooth, graphics, input, laptop, nixos, power, steam-hardware
│   ├── roles/               # default, workstation, dev, gaming
│   ├── secrets/             # agenix
│   ├── services/            # avahi, openssh, printing, samba, smartd, tailscale
│   └── virtualization/      # libvirt, podman, waydroid, vm-variant, looking-glass, windows-vm
├── classes/                 # devenv, files, nix-unit, formatter
├── core/                    # impermanence, policies, quirks
├── flake-parts/             # devenv, diagrams, files, flake-file, flake-root, formatter, meta, pkgs, wrappers
├── hosts/                   # nixos, super, sandbox
└── users/                   # artifex
```

### Quirks (Pipe Data)

Cross-cutting concerns collected from aspects and aggregated at host/user scope:
`autostart` `cache` `cacheHome` `codium-extensions` `codium-settings` `firewall` `homeManagerModules` `nixpkgs-overlays` `persist` `persistHome` `secrets` `secretsHome`

## Topology & Hosts

Hosts and user topologies are declared in [`modules/hosts/`](modules/hosts):

| Host | Architecture | User | Roles & Aspects |
|------|--------------|------|-----------------|
| **`nixos`** | `x86_64-linux` | `artifex` | `roles.default`, `roles.workstation`, `roles.dev`, `roles.gaming`, `hardware.nixos`, `impermanence`, `secrets.agenix` |
| **`super`** | `x86_64-linux` | `artifex` | `roles.default`, `roles.workstation`, `roles.dev`, `roles.gaming`, `impermanence`, `secrets.agenix` |
| **`sandbox`** | `x86_64-linux` | `artifex` | `roles.default`, `applications.gaming.nix-ld` (Isolated testbed host for rapid VM testing) |

## Development Environment (`devenv` + `direnv`)

The repository includes a reproducible developer environment configured in [`modules/flake-parts/devenv.nix`](modules/flake-parts/devenv.nix) and integrated via `.envrc`.

### Activation

1. Ensure [direnv](https://direnv.net/) and [nix-direnv](https://github.com/nix-community/nix-direnv) are installed.
2. Allow the environment in the repo root:
   ```bash
   direnv allow
   ```
3. Alternatively, enter the shell manually:
   ```bash
   nix develop
   ```

## System Deployment (`nh`)

Deploy system configurations safely using [`nh`](https://github.com/viperML/nh):

```bash
# Build toplevel derivation
nh os build

# Test build in a transient generation
nh os test

# Switch system generation and activate (with git-labeled generation & rollback protection)
rebuild-switch # or: rebuild

# Standard switch via nh
nh os switch

# Manage, inspect, and prune generations interactively with Television
tv nix-generations # or: nhg, generations
```

## Diagrams & Topology

Generate fleet visualization diagrams and update `TOPOLOGY.md`:

```bash
nix run .#write-topology
```
