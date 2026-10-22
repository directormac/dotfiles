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
│   ├── disk/                # Disko declarative partitioning layouts (btrfs.nix; `settings.disk.btrfs.device` is REQUIRED per host, no default)
│   ├── hardware/            # Hardware profiles and GPU/input/power leaves (bluetooth, graphics/*, input, laptop, power, steam-hardware)
│   ├── roles/               # Role aggregators (default, workstation, dev, gaming)
│   ├── secrets/             # Secret management (agenix.nix)
│   ├── services/            # System daemons (avahi, openssh, printing, samba, smartd, tailscale)
│   └── virtualization/      # Containers & VMs (libvirt, podman, waydroid, vm-variant, looking-glass, windows-vm)
├── classes/                 # Custom Den class routes (devenv, files, formatter/treefmt, nix-unit `tests`)
├── core/                    # Framework wiring (dotfiles, impermanence, capabilities, policies, quirks, settings, _settings-type)
├── flake-parts/             # Flake-level plumbing and generated file definitions (files/{readme,agents,bootstrap,migration,envrc,gitignore}.nix)
├── hosts/                   # Host declarations (nixos.nix + nixos/hardware.nix = legacy SATA install; super.nix = NVMe target with disk.btrfs; sandbox.nix = VM testbed)
└── users/                   # User declarations (artifex.nix)
pkgs/
├── overlays.nix             # Auto-discovers pkgs/by-name/* into `pkgs.local.<name>` and top-level `pkgs.<name>`
└── by-name/<pkg>/package.nix
config/                      # Live mutable/out-of-store application configs linked via `config.lib.dots.link`
```

### Den Entity, Scope & Aspect Model
- **Choosing a Den Mechanism**:
  | Goal | Den Mechanism |
  | :--- | :--- |
  | Bundle aspects so one brings others | `includes = [ ... ]` on the aspect |
  | Configure OS / Home Manager | Class keys: `nixos`, `darwin`, `os` (platform-agnostic OS), `user` (`users.users.<name>`), `homeManager` |
  | Vary config by host or user | Class module taking `{ host, ... }` / `{ user, ... }`, or a parametric aspect |
  | Apply an aspect to every entity | `den.schema.<kind>.includes` (`host`, `user`, `home`, `flake-parts`), or `den.default.includes` for all |
  | Per-aspect typed tunables | `settings.<opt> = lib.mkOption { ... }` on the aspect, read as `host.settings.<aspect>.<opt>` or `user.settings.<aspect>.<opt>` (`modules/core/settings.nix` + `modules/core/_settings-type.nix`) |
  | Gate config on another aspect | Structural introspection: `host.hasAspect den.aspects.<path>` / `user.hasAspect den.aspects.<path>` inside `lib.mkIf` |
  | Share structured data across aspects | Quirks (`den.quirks.<name>` in `modules/core/quirks.nix`); cross scopes via `den.lib.policy.pipe.expose` / `pipe.collect` (`modules/core/policies.nix`) |
  | Forward custom class into another class | `den.classes.<name>` + `den.lib.policy.route` (`modules/classes/*.nix`) |
- **Scope Isolation & Where Config Lands**:
  - **Host scope** walks `den.aspects.<host>`, its `includes`, and `den.schema.host.includes`, delivering `nixos`, `darwin`, and `os`. `homeManager` keys on host-included aspects reach users only when the user opts in via `den.batteries.host-aspects` (which `artifex` includes) or via `provides.to-users`.
  - **User scope** walks `den.aspects.<user>`, its `includes`, and `den.schema.user.includes`, delivering `homeManager` to `home-manager.users.<name>` and `user` to `users.users.<name>` (`den.schema.user.classes = [ "user" "homeManager" ]` in `modules/defaults.nix`). Inside a `user` class module, `osConfig` (or `config`) accesses the host's OS config.
  - **Never use untargeted `nixos` on a user aspect** (Den issue `#694`): use the `user` class for the user's own OS account (`modules/users/artifex.nix`), `provides.to-hosts.nixos` / `provides.<host>.nixos` for explicit host OS changes, and `den.policies.project-user-quirks` (`pipe.expose` in `modules/core/policies.nix`) for user-emitted system quirks (`nixpkgs-overlays`, `persist`, `cache`, `firewall`, `secrets`).
- **Quirks (Pipe Data)**: `persist`, `cache`, `persistHome`, `cacheHome`, `autostart`, `firewall`, `nixpkgs-overlays`, `homeManagerModules`, `codium-extensions`, `codium-settings`, `secrets`, `secretsHome`.
- **Batteries in `den.default.includes`**: `den.batteries.define-user` (automatically creates `users.users.<name>` and sets `home.username` / `home.homeDirectory`), `den.batteries.hostname` (sets `networking.hostName` from `den.hosts.<system>.<name>`), `den.batteries.inputs'`, and `den.batteries.self'`.

## 2. Generated Files & Synchronization Invariants

Several root files are generated declaratively. **NEVER** edit generated target files by hand—always edit their Nix source modules and run the corresponding generator:

| Generated File | Source Module(s) | Generator Command |
| :--- | :--- | :--- |
| `flake.nix` | `modules/flake-parts/flake-file.nix` + `flake-file.inputs` across aspects | `nix run .#write-flake` |
| `README.md` | `modules/flake-parts/files/readme.nix` (`flake.readme.*` DAG) | `nix run .#write-files` |
| `AGENTS.md` | `modules/flake-parts/files/agents.nix` (`flake.agents.*` DAG) | `nix run .#write-files` |
| `BOOTSTRAP.md` | `modules/flake-parts/files/bootstrap.nix` (`flake.bootstrap.*` DAG) | `nix run .#write-files` |
| `MIGRATION.md` | `modules/flake-parts/files/migration.nix` (`flake.migration.*` DAG) | `nix run .#write-files` |
| `.envrc` | `modules/flake-parts/files/envrc.nix` (`flake.dot-envrc.*` DAG) | `nix run .#write-files` |
| `.gitignore` | `modules/flake-parts/files/gitignore.nix` (`flake.dot-gitignore.*` DAG) | `nix run .#write-files` |
| `.workmux.yaml` | `modules/aspects/applications/dev/mux/workmux.nix` | `nix run .#write-files` |
| `.treefmt.toml` | `modules/flake-parts/formatter.nix` | `nix run .#write-files` |
| `TOPOLOGY.md` | `modules/flake-parts/diagrams.nix` | `nix run .#diagrams.write-topology` |

> **Note:** `.nvim.lua` at the repository root is a hand-maintained project-local Neovim `exrc` file (not generated by `write-files`).

### Adding a New Generated Markdown File
Follow the pattern in `modules/flake-parts/files/readme.nix`:
1. Create `modules/flake-parts/files/<name>.nix`.
2. Define `options.flake.<name>` with `lib.types.lazyAttrsOf lib.types.unspecified`.
3. Populate `config.flake.<name>.<section>` using `dag.entryBefore`, `dag.entryBetween [ "before" ] [ "after" ]`, or `dag.entryAfter`.
4. Set `perSystem = _: { files.file."<FILENAME>.md".text = dag.render { entries = config.flake.<name>; separator = "\n"; }; };`.
5. Run `git add -N modules/flake-parts/files/<name>.nix && nix run .#write-files`.

## 3. Impermanence & Config Persistence Rules

Hosts that include `disk.btrfs` (`super`) roll `/` back to an empty Btrfs snapshot (`root-blank`) on every boot via the initrd service `rollback-root` (`modules/core/impermanence.nix`). State must be explicitly routed through the four persistence quirks.

> **Host reality check:** the rollback looks up `/dev/disk/by-label/nixos` and **silently exits 0 if it is missing**. The legacy `nixos` host (`modules/hosts/nixos/hardware.nix`) runs on a plain btrfs top-level (`subvol=/`, label `root`) where `/persist` and `/cache` are ordinary directories, so root is **never wiped there**. Missing `persist*` entries are therefore invisible on `nixos` and only break on a `disk.btrfs` host. When reviewing persistence changes, reason against the `super` layout, not the behavior of the running machine. Moving between the two is documented in `MIGRATION.md`.

### Choosing Between `persist` / `persistHome` and `cache` / `cacheHome`
- **`persist` (`/persist`) & `persistHome` (`/persist/home/<user>`)**:
  - Use **ONLY** for irreplaceable state, identity, credentials, history, sessions, and user-edited application state:
    - System: `/etc/machine-id`, `/etc/ssh/ssh_host_*_key`, `/var/lib/systemd/credential.secret`, `/var/lib/nixos`, `/var/lib/tailscale`, `/var/lib/bluetooth`, `/var/lib/libvirt`, `/etc/NetworkManager/system-connections`, `/var/lib/NetworkManager`.
    - User: `.ssh`, `.gnupg`, `.config/agenix`, `.local/share/keyrings`, browser profiles (`.config/zen`, `.mozilla`, `.config/chromium`), `.local/state/tmux` (resurrect), `.local/share/zsh` & `.histdb`, `.local/state/nvim` & `.local/share/nvim`, `.local/share/opencode` & `.local/state/opencode`, mutable app configs in `.config/*`.
- **`cache` (`/cache`) & `cacheHome` (`/cache/home/<user>`)**:
  - Use for **regenerable or re-downloadable data** persisted across reboots only to avoid re-downloading or rebuilding:
    - System: `/var/tmp`, `/srv`, `/var/lib/containers`.
    - User: `Downloads`, `.cache`, `.local/share/nix`, `.local/share/direnv`, `.local/share/devenv`, `.local/share/mise` & `.cache/mise`, `.npm`, `.bun`, `.local/share/vite-plus`, `.cargo`, `.rustup`, `.config/go`, `.cache/uv` & `.local/share/uv`, `.cache/nix-index`, browser caches (`.cache/zen`, `.cache/mozilla`, `.cache/chromium`), Electron caches (`.config/ZenNotes`), `.local/share/containers`, `.local/share/Steam` & `.steam`.

### Impermanence, Browser, Tmux & Formatter Invariants
1. **Do NOT bind-mount directories managed purely as Home Manager store symlinks**:
   - If Home Manager creates symlinks inside a directory (e.g., `xdg.dataFile."helix/runtime/grammars"`), bind-mounting the parent directory in `persistHome` causes `hm-activate` to fail with `rmdir: failed to remove directory '...': Device or resource busy` when cleaning orphan links.
2. **Automatic Subpath Deduplication (`modules/core/impermanence.nix`)**:
   - `den.aspects.impermanence.collect` normalizes relative home paths (stripping any accidental `~/` prefix or trailing `/`) and automatically filters out subdirectories whose parent directory is already persisted in the same pool (e.g., `.cache/<app>` under `.cache`), preventing duplicate self-bind-mounts.
3. **Worktree-Aware Live Config Symlinks (`modules/core/dotfiles.nix`)**:
   - Configs that remain live-editable without rebuilding NixOS live in `config/<app>` and **MUST** be linked via the central Home Manager helpers defined in `modules/core/dotfiles.nix` (never repeat `let dotsPath = ...` in aspects):
     ```nix
     { config, ... }:
     {
       xdg.configFile."<app>".source = config.lib.dots.link "<app>";
       # Or for plain path strings inside scripts:
       # exec ${config.lib.dots.path "<app>/run.sh"} "$@"
     }
     ```
   - `config.dots.configPath` defaults to `user.dotsConfigPath` (`modules/core/settings.nix`), which resolves `$DOTFILES_ROOT` / `$NH_FLAKE` when evaluated with `--impure` (exported automatically by `rebuild-switch` and the `nh` wrapper in `modules/aspects/core/nh.nix` when working inside a git worktree under `~/Code/.worktrees/.dotfiles/<branch>`) and falls back to `/home/<user>/.dotfiles/config` under pure evaluation.
   - Because `.dotfiles` and `Code` are persisted via `persistHome`, out-of-store symlinks into `config/` are automatically persistent and do **not** need a duplicate `persistHome` entry for `.config/<app>`.
4. **Browser Authentication & Keyring Persistence**:
   - Gecko browsers (`zen.nix`, `firefox.nix`, `librewolf.nix`) share `common.sessionSettings` from `modules/aspects/applications/browsers/_common/default.nix` (`browser.startup.page = 3`, `privacy.sanitize.sanitizeOnShutdown = false`, `privacy.clearOnShutdown* = false`, and `services.sync.prefs.sync.privacy.* = false`) so session cookies and site storage survive reboots and LibreWolf's defaults are never synced over Firefox Sync.
   - Chromium and Google Chrome (`chromium.nix`) pass `--password-store=gnome-libsecret` and persist `.pki` alongside `.config/chromium` and `.config/google-chrome`, while `modules/aspects/core/security.nix` enables `enableGnomeKeyring = true` on `sddm`, `greetd`, `gdm`, and `login` PAM services so cookie encryption keys stay unlocked across boots.
   - **The persisted login keyring is only useful if it unlocks at login.** PAM unlocks `~/.local/share/keyrings/login.keyring` with the login password. If that password differs from the account password, the journal shows `gnome-keyring-daemon: failed to unlock login keyring on startup`, `busctl --user get-property org.freedesktop.secrets /org/freedesktop/secrets/collection/login org.freedesktop.Secret.Collection Locked` prints `b true`, and every libsecret client (Antigravity CLI `agy`, Chromium cookies, Bitwarden) asks to log in again after each reboot even though the files persist. Fix the data, not the Nix: change the keyring password to the login password in Seahorse, or move `login.keyring` aside and log in once through the display manager so PAM creates a new one.
5. **Tmux Resurrect & Continuum Session Restore (`modules/aspects/applications/dev/mux/tmux/`)**:
   - Save and restore use lock-protected, self-healing wrappers (`resurrectSaveScript` and `resurrectRestoreScript` in `tmux.nix`) that refuse to save 0-pane servers during shutdown teardown, avoid same-second `save.sh` filename collisions that delete `last`, and repair `last` if dangling or empty.
   - `systemd.user.services.tmux-server` (`_systemd.nix`) runs `resurrectRestoreScript` in `ExecStartPost` via `tmux run-shell` (which populates `$TMUX` so `restore.sh` resolves the server socket).
6. **Neovim `conform.nvim` & `treefmt` Invariant (`modules/flake-parts/formatter.nix`)**:
   - **NEVER** add `**/.conform.*` or `**/_*` to `treefmt`'s `settings.global.excludes`. `conform.nvim` invokes `treefmt` with `stdin = false` on temporary `.conform.<id>.<filename>` files next to the buffer; excluding `**/.conform.*` causes `treefmt` to skip every file saved in Neovim.
7. **Disk Safety (`modules/aspects/disk/btrfs.nix`)**:
   - `settings.disk.btrfs.device` intentionally has **no default**; set it per host on `den.hosts.<system>.<host>.settings.disk.btrfs.device` as a `/dev/disk/by-id/...` path. A default pointing at a disk in use makes `disko` wipe it.
   - **NEVER** run `disko`, `mkfs`, `wipefs`, `sgdisk`, `rsync --delete` into `/persist`, or any other destructive disk command unless the user explicitly asks. Verify with `nix build .#nixosConfigurations.<host>.config.system.build.diskoScript` and `grep -o '/dev/disk/by-id/[^ ;")]*' result | sort -u` instead.
8. **Host Hardware Parity**:
   - `hardware.nixos` (legacy host) imports `not-detected.nix`, which enables `hardware.enableRedistributableFirmware` and Intel microcode. A host built from `disk.btrfs` gets filesystems from Disko but **no firmware**; set `hardware.enableRedistributableFirmware` and `hardware.cpu.<vendor>.updateMicrocode` in the host module (as `modules/hosts/super.nix` does) or Wi-Fi/Bluetooth firmware and microcode silently disappear.
9. **Agenix Host Key, Passwords & Hostname Fallback (`modules/aspects/secrets/agenix.nix`, `modules/users/artifex.nix`)**:
   - Secrets decrypt with `/persist/etc/ssh/ssh_host_ed25519_key`. A host without `.secrets/hosts/<host>.pub` falls back to `.secrets/hosts/super.pub` and `.secrets/rekeyed/super/`.
   - Because `/` (including `/etc/shadow`) is wiped on every boot by `impermanence.rollback-btrfs`, passwords set with `passwd` do not survive reboots. Run `nix run .#set-password` (or `set-password` in the devshell) to create `.secrets/users/artifex/password.age` (`hashedPasswordFile` for both `artifex` and `root`, or `set-password root` for a separate `root-password.age`), rekey it for all hosts, and synchronize `~/.local/share/keyrings/login.keyring` in place.

## 4. Flake Inputs, Overlays & Local Packages

### Declaring Flake Inputs
- Co-locate `flake-file.inputs.<input>` inside the aspect module that uses it.
- Always guard optional or third-party flake inputs in module bodies (e.g., `lib.optionals (inputs ? foo) [ ... ]` or `inputs.foo.nixosModules.default or { }`) so evaluation remains resilient.
- After adding or changing `flake-file.inputs`, run `nix run .#write-flake` to update `flake.nix`.

### Local Packages (`pkgs/by-name`)
- Custom packages and scripts (`rebuild-switch`, `set-password`, `nix-generations`, `nix-flake-build`, `nix-flake-update`, `update-pkgs`, `rmpd`, `zsh-histdb`, etc.) live in `pkgs/by-name/<name>/package.nix`.
- `pkgs/overlays.nix` automatically exposes every directory in `pkgs/by-name` as `pkgs.local.<name>` and `pkgs.<name>`, and exports them in `flake.packages.<system>.<name>`.

## 5. Verification, Formatting & Workflow Commands

### Fast Evaluation Checks (Run First)
Before running full builds or `nix flake check`, verify host evaluations quickly:
```bash
# Evaluate host toplevel derivations (fast, catches syntax/type/option errors)
nix eval .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath
nix eval .#nixosConfigurations.super.config.system.build.toplevel.drvPath
nix eval .#nixosConfigurations.sandbox.config.system.build.toplevel.drvPath
# Evaluate the Disko script for hosts that include disk.btrfs (does not touch any disk)
nix build --no-link .#nixosConfigurations.super.config.system.build.diskoScript
```

### Synchronize Generated Files & Format
```bash
# 1. Regenerate flake.nix if flake-file.inputs changed
nix run .#write-flake

# 2. Regenerate README.md, AGENTS.md, BOOTSTRAP.md, MIGRATION.md, .envrc, .gitignore, .workmux.yaml, .treefmt.toml
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
- **Agent Safety Rule (disks)**: never format, partition, mount over, or `rsync --delete` real disks; produce commands for the user to run instead.

## 6. Working Conventions & Debugging

### Adding or Changing Things
- **One aspect per concern.** A new app or service is a leaf aspect under the matching `modules/aspects/<area>/`. It declares its own `flake-file.inputs`, imports any third-party NixOS/Home Manager module in its own class (`nixos.imports = [ inputs.foo.nixosModules.default ]`), emits its persistence through quirks, and is pulled in by a role (`modules/aspects/roles/*.nix`) or host `includes`. Hosts never import third-party modules directly.
- **Per-host differences are settings, not conditionals.** Add a typed `settings.<opt>` to the aspect and set it on `den.hosts.<system>.<host>.settings.<aspect>.<opt>` (see `desktop.hyprland.cardDevice`, `disk.btrfs.device`). Do not branch on `host.name`.
- **Do not repeat yourself across aspects.** Shared helpers live in `modules/core/` (`dotfiles.nix`, `impermanence.nix`) or an underscore-prefixed `_common/` directory next to the consumers; extend them instead of copying `let` blocks.
- **Keep modules small and commented.** Start each module with a one-line `#` comment describing it; match the surrounding aspect's structure and `nixfmt-rs` formatting.
- **Commit style:** conventional commits as in `git log` (`feat:`, `fix:`, `refactor:`), one concern per commit. Generated files are committed together with their source module.

### Debugging Den Evaluation
- Read a merged value directly: `nix eval .#nixosConfigurations.<host>.config.<option> --json`; add `--show-trace` for module errors.
- Interactive: `nix repl` then `:lf .` and inspect `nixosConfigurations.<host>.config...`.
- Print or break at an include: `({ host, ... }@ctx: builtins.trace ctx { nixos = { }; })` or `builtins.break ctx`; remove before committing.
- Policy routing: `den.lib.policyInspect.inspect { kind = "host"; context = { host = den.hosts.x86_64-linux.super; }; }` shows which policies apply and where they route. Exposing `flake.den = den;` temporarily makes `den` visible in the REPL; never commit it.
- Compare hosts before trusting a refactor: evaluate the same option on `nixos`, `super`, and `sandbox` (for example `fileSystems`, `hardware.enableRedistributableFirmware`, `boot.initrd.systemd.enable`). Differences are expected only where the host includes different aspects.
