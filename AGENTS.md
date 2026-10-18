# AGENTS.md — AI Coding Agent Guide

This file provides architectural context, invariants, and workflow rules for AI coding agents working in this repository.

> **Note:** `AGENTS.md` is a generated file managed via [`modules/flake-parts/files/agents.nix`](modules/flake-parts/files/agents.nix). Never edit `AGENTS.md` directly—modify `modules/flake-parts/files/agents.nix` and run `nix run .#write-files`.

## 1. Repository Architecture & Module Discovery

This repository is a pure-leaf dendritic NixOS and Home Manager configuration powered by **[Den](https://den.denful.dev)**, **[flake-parts](https://flake.parts/)**, **[import-tree](https://github.com/denful/import-tree)**, and **[flake-file](https://github.com/denful/flake-file)**.

### Automatic Import (`import-tree`)
- Every `.nix` file under `modules/` is a `flake-parts` module and is **automatically imported** by `import-tree`.
- Files or directories prefixed with an underscore (`_`, e.g., `modules/core/_settings-type.nix`, `modules/aspects/applications/shell/zsh/_aliases.nix`, `modules/aspects/applications/browsers/_common/`) are **ignored** by `import-tree` and imported explicitly by their parent module when needed.
- **NEVER** add manual `imports = [ ./foo.nix ];` for normal modules under `modules/`.
- **CRITICAL (Nix Flakes & Git Tracking):** Nix flakes ignore untracked files in a Git repository. Whenever you create a new file under `modules/` or `pkgs/`, you **MUST** stage its intent with `git add -N <path>` (or `git add <path>`) before running `nix eval`, `nix build`, `nix flake check`, or `nix run`.

### Directory Layout
```text
modules/
├── aspects/
│   ├── applications/        # Leaf aspects for CLI, TUI, and GUI apps (browsers, dev, gaming, media, messaging, productivity, shell, terminals, wayland)
│   ├── core/                # System foundation leaves (boot, documentation, locale, mounts, networking, nh, nix, nixpkgs, security, users)
│   ├── desktop/             # Compositors (hyprland, niri, mangowm, dms, noctalia) and desktop services (audio, fonts, greeter, gtk, kdeconnect, nautilus, stylix, thunar, udiskie, xdg, xserver)
│   ├── disk/                # Disko declarative partitioning layouts (btrfs.nix)
│   ├── hardware/            # Hardware profiles and GPU/input/power leaves (bluetooth, graphics/*, input, laptop, nixos, power, steam-hardware)
│   ├── roles/               # Role aggregators (default, workstation, dev, gaming)
│   ├── secrets/             # Secret management (agenix.nix)
│   ├── services/            # System daemons (avahi, openssh, printing, samba, smartd, tailscale)
│   └── virtualization/      # Containers & VMs (libvirt, podman, waydroid, vm-variant, looking-glass, windows-vm)
├── classes/                 # Den class forwarders (devenv, files, formatter, nix-unit)
├── core/                    # Framework wiring (impermanence, capabilities, policies, quirks, settings, _settings-type)
├── flake-parts/             # Flake-level plumbing and generated file definitions (files/{readme,agents,bootstrap}.nix)
├── hosts/                   # Host declarations (nixos.nix, super.nix, sandbox.nix)
└── users/                   # User declarations (artifex.nix)
pkgs/
├── overlays.nix             # Auto-discovers pkgs/by-name/* into `pkgs.local.<name>` and top-level `pkgs.<name>`
└── by-name/<pkg>/package.nix
config/                      # Live mutable/out-of-store application configs symlinked via `user.dotsConfigPath`
```

### Entity & Aspect Model
- **Leaf Aspects (`den.aspects.<category>...<name>`)**: Self-contained feature modules. A single leaf aspect can define:
  - `nixos`: NixOS module configuration
  - `homeManager`: Home Manager module configuration
  - `includes`: List of other aspects to include
  - `settings`: Typed per-aspect options exposed at `host.settings.<aspect-path>` and `user.settings.<aspect-path>` (powered by `modules/core/settings.nix`)
  - `flake-file.inputs`: Flake inputs required by the aspect
  - **Quirks (Pipe Data)**: `persist`, `cache`, `persistHome`, `cacheHome`, `autostart`, `firewall`, `nixpkgs-overlays`, `homeManagerModules`, `codium-extensions`, `codium-settings`, `secrets`, `secretsHome`
- **Roles (`den.aspects.roles.{default,workstation,dev,gaming}`)**: Pure composition aspects that group leaf aspects via `includes`.
- **Hosts (`modules/hosts/<host>.nix`)**: Define both `den.aspects.<host>` (which includes roles, hardware, disk, secrets, and `impermanence`) and `den.hosts.<system>.<host>` (which binds users and host settings).
- **Users (`modules/users/<user>.nix`)**: Define `den.aspects.<user>` using `den.batteries.host-aspects`, `den.batteries.primary-user`, and `(den.batteries.user-shell "zsh")`.

## 2. Generated Files & Synchronization Invariants

Several root files are generated declaratively. **NEVER** edit generated target files by hand—always edit their Nix source modules and run the corresponding generator:

| Generated File | Source Module(s) | Generator Command |
| :--- | :--- | :--- |
| `flake.nix` | `modules/flake-parts/flake-file.nix` + `flake-file.inputs` across aspects | `nix run .#write-flake` |
| `README.md` | `modules/flake-parts/files/readme.nix` (`flake.readme.*` DAG) | `nix run .#write-files` |
| `AGENTS.md` | `modules/flake-parts/files/agents.nix` (`flake.agents.*` DAG) | `nix run .#write-files` |
| `BOOTSTRAP.md` | `modules/flake-parts/files/bootstrap.nix` (`flake.bootstrap.*` DAG) | `nix run .#write-files` |
| `.workmux.yaml` | `modules/aspects/applications/dev/mux/workmux.nix` | `nix run .#write-files` |
| `.nvim.lua` | `modules/aspects/applications/dev/editor/neovim.nix` | `nix run .#write-files` |
| `.treefmt.toml` | `modules/flake-parts/formatter.nix` | `nix run .#write-files` |
| `TOPOLOGY.md` | `modules/flake-parts/diagrams.nix` | `nix run .#diagrams.write-topology` |

### Adding a New Generated Markdown File
Follow the pattern in `modules/flake-parts/files/readme.nix`:
1. Create `modules/flake-parts/files/<name>.nix`.
2. Define `options.flake.<name>` with `lib.types.lazyAttrsOf lib.types.unspecified`.
3. Populate `config.flake.<name>.<section>` using `dag.entryBefore`, `dag.entryBetween [ "before" ] [ "after" ]`, or `dag.entryAfter`.
4. Set `perSystem = _: { files.file."<FILENAME>.md".text = dag.render { entries = config.flake.<name>; separator = "\n"; }; };`.
5. Run `git add -N modules/flake-parts/files/<name>.nix && nix run .#write-files`.

## 3. Impermanence & Config Persistence Rules

Root (`/`) is rolled back to an empty Btrfs snapshot (`root-blank`) on every boot (`modules/core/impermanence.nix`). State must be explicitly routed through the four persistence quirks:

### Choosing Between `persist` / `persistHome` and `cache` / `cacheHome`
- **`persist` (`/persist`) & `persistHome` (`/persist/home/<user>`)**:
  - Use **ONLY** for irreplaceable state, identity, credentials, history, sessions, and user-edited application state:
    - System: `/etc/machine-id`, `/etc/ssh/ssh_host_*_key`, `/var/lib/systemd/credential.secret`, `/var/lib/nixos`, `/var/lib/tailscale`, `/var/lib/bluetooth`, `/var/lib/libvirt`, `/etc/NetworkManager/system-connections`, `/var/lib/NetworkManager`.
    - User: `.ssh`, `.gnupg`, `.config/agenix`, `.local/share/keyrings`, browser profiles (`.config/zen`, `.mozilla`, `.config/chromium`), `.local/state/tmux` (resurrect), `.local/share/zsh` & `.histdb`, `.local/state/nvim` & `.local/share/nvim`, `.local/share/opencode` & `.local/state/opencode`, mutable app configs in `.config/*`.
- **`cache` (`/cache`) & `cacheHome` (`/cache/home/<user>`)**:
  - Use for **regenerable or re-downloadable data** persisted across reboots only to avoid re-downloading or rebuilding:
    - System: `/var/tmp`, `/srv`, `/var/lib/containers`.
    - User: `Downloads`, `.cache`, `.local/share/nix`, `.local/share/direnv`, `.local/share/devenv`, `.local/share/mise` & `.cache/mise`, `.npm`, `.bun`, `.local/share/vite-plus`, `.cargo`, `.rustup`, `.config/go`, `.cache/uv` & `.local/share/uv`, `.cache/nix-index`, browser caches (`.cache/zen`, `.cache/mozilla`, `.cache/chromium`), Electron caches (`.config/ZenNotes`), `.local/share/containers`, `.local/share/Steam` & `.steam`.

### Impermanence Pitfalls to Avoid
1. **Do NOT bind-mount directories managed purely as Home Manager store symlinks**:
   - If Home Manager creates symlinks inside a directory (e.g., `xdg.dataFile."helix/runtime/grammars"`), bind-mounting the parent directory in `persistHome` causes `hm-activate` to fail with `rmdir: failed to remove directory '...': Device or resource busy` when cleaning orphan links.
2. **Out-of-Store Live Config Symlinks (`config/`)**:
   - Configs that should remain live-editable without rebuilding NixOS live in `config/<app>` and are symlinked via:
     ```nix
     let
       dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
     in
     {
       xdg.configFile."<app>".source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/<app>";
     }
     ```
   - Because `.dotfiles` is persisted via `persistHome`, out-of-store symlinks into `config/` are automatically persistent and do **not** need a duplicate `persistHome` entry for `.config/<app>`.

## 4. Flake Inputs, Overlays & Local Packages

### Declaring Flake Inputs
- Co-locate `flake-file.inputs.<input>` inside the aspect module that uses it.
- Always guard optional or third-party flake inputs in module bodies (e.g., `lib.optionals (inputs ? foo) [ ... ]` or `inputs.foo.nixosModules.default or { }`) so evaluation remains resilient.
- After adding or changing `flake-file.inputs`, run `nix run .#write-flake` to update `flake.nix`.

### Local Packages (`pkgs/by-name`)
- Custom packages and scripts (`rebuild-switch`, `nix-generations`, `nix-flake-build`, `nix-flake-update`, `update-pkgs`, `rmpd`, `zsh-histdb`, etc.) live in `pkgs/by-name/<name>/package.nix`.
- `pkgs/overlays.nix` automatically exposes every directory in `pkgs/by-name` as `pkgs.local.<name>` and `pkgs.<name>`, and exports them in `flake.packages.<system>.<name>`.

## 5. Verification, Formatting & Workflow Commands

### Fast Evaluation Checks (Run First)
Before running full builds or `nix flake check`, verify host evaluations quickly:
```bash
# Evaluate host toplevel derivations (fast, catches syntax/type/option errors)
nix eval .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath
nix eval .#nixosConfigurations.super.config.system.build.toplevel.drvPath
nix eval .#nixosConfigurations.sandbox.config.system.build.toplevel.drvPath
```

### Synchronize Generated Files & Format
```bash
# 1. Regenerate flake.nix if flake-file.inputs changed
nix run .#write-flake

# 2. Regenerate README.md, AGENTS.md, BOOTSTRAP.md, .workmux.yaml, .nvim.lua
nix run .#write-files

# 3. Regenerate TOPOLOGY.md if hosts, aspects, or quirks changed
nix run .#diagrams.write-topology

# 4. Format Nix and Lua files (nixfmt-rs, deadnix, statix, stylua)
nix fmt modules/ pkgs/

# 5. Run flake evaluation checks without building all derivations
nix flake check --no-build
```

### Building & Deploying
- **Build without switching**: `nh os build` or `nix-flake-build <host>`
- **Test in transient generation**: `nh os test`
- **Activate & switch with rollback protection**: `rebuild-switch` (labels the generation `<branch>-<scope>-<rev>-<timestamp>` and automatically rolls back and deletes the generation if activation fails).
- **Agent Safety Rule**: Do **not** run `rebuild-switch` or `nh os switch` unless explicitly asked by the user; use `nix eval` or `nh os build` to verify changes safely.
