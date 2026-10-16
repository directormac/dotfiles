{
  dag,
  config,
  lib,
  ...
}:
{
  options.flake.readme = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.unspecified;
    default = { };
    description = "DAG of sections to assemble into README.md";
  };

  config = {
    flake.readme.header =
      dag.entryBefore [ "links" ]
        # markdown
        ''
          # Den Dotfiles Configuration

          A modern, pure-leaf dendritic NixOS and Home Manager configuration powered by [Den](https://den.denful.dev), [flake-file](https://github.com/denful/flake-file), [devenv](https://devenv.sh), and [agenix-rekey](https://github.com/oddlama/agenix-rekey).
        '';

    flake.readme.links =
      dag.entryBetween [ "disallow-warnings" ] [ "header" ]
        # markdown
        ''
          ## Quick Links
          - [Awesome Nix](https://github.com/nix-community/awesome-nix)
          - [Den Documentation](https://den.denful.dev)
          - [NixOS Options Search](https://search.nixos.org/options?channel=unstable)
          - [Home Manager Options](https://home-manager-options.extranix.com/)
          - [devenv Documentation](https://devenv.sh/)
          - [flake-parts Documentation](https://flake.parts/)
        '';

    flake.readme.disallow-warnings =
      dag.entryBetween [ "files" ] [ "links" ]
        # markdown
        ''
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
        '';

    flake.readme.files =
      dag.entryBetween [ "automatic-import" ] [ "disallow-warnings" ]
        # markdown
        ''
          ## Generated Files

          The following files in this repository are generated and managed
          using [the files flake-parts module](https://github.com/sini/files):

          - `README.md`
          - `.workmux.yaml`
          - `.nvim.lua`
        '';

    flake.readme.automatic-import =
      dag.entryBetween [ "den" ] [ "files" ]
        # markdown
        ''
          ## Automatic Import

          Nix files (they're all flake-parts modules) are automatically imported via [import-tree](https://github.com/denful/import-tree).
          Nix files prefixed with an underscore are ignored.
          No literal path imports are used.
          This means files can be moved around and nested in directories freely.
        '';

    flake.readme.den =
      dag.entryBetween [ "hosts" ] [ "automatic-import" ]
        # markdown
        ''
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
        '';

    flake.readme.hosts =
      dag.entryBetween [ "devenv" ] [ "den" ]
        # markdown
        ''
          ## Topology & Hosts

          Hosts and user topologies are declared in [`modules/hosts/`](modules/hosts):

          | Host | Architecture | User | Roles & Aspects |
          |------|--------------|------|-----------------|
          | **`nixos`** | `x86_64-linux` | `artifex` | `roles.default`, `roles.workstation`, `roles.dev`, `roles.gaming`, `hardware.nixos`, `secrets.agenix` |
          | **`super`** | `x86_64-linux` | `artifex` | `roles.default`, `roles.workstation`, `roles.dev`, `roles.gaming`, `impermanence`, `secrets.agenix` |
          | **`sandbox`** | `x86_64-linux` | `artifex` | `roles.default`, `applications.gaming.nix-ld` (Isolated testbed host for rapid VM testing) |
        '';

    flake.readme.devenv =
      dag.entryBetween [ "deployment" ] [ "hosts" ]
        # markdown
        ''
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
        '';

    flake.readme.deployment =
      dag.entryAfter [ "devenv" ]
        # markdown
        ''
          ## System Deployment (`nh`)

          Deploy system configurations safely using [`nh`](https://github.com/viperML/nh):

          ```bash
          # Build toplevel derivation
          nh os build

          # Test build in a transient generation
          nh os test

          # Switch system generation and activate
          nh os switch
          ```

          ## Diagrams & Topology

          Generate fleet visualization diagrams and update `TOPOLOGY.md`:

          ```bash
          nix run .#write-topology
          ```
        '';

    perSystem = _: {
      files.file."README.md".text = dag.render {
        entries = config.flake.readme;
        separator = "\n";
      };
    };
  };
}
