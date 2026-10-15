{
  perSystem = {
    files.file = {
      "README.md" = {
        text =
          # md
          ''
            # Den Dotfiles Configuration

            A modern, pure-leaf dendritic NixOS and Home Manager configuration powered by [Den](https://den.denful.dev), [flake-file](https://github.com/denful/flake-file), [devenv](https://devenv.sh), and [agenix-rekey](https://github.com/oddlama/agenix-rekey).

            ---

            ## Quick Links

            - [Den Documentation](https://den.denful.dev)
            - [NixOS Options Search](https://search.nixos.org/options?channel=unstable)
            - [Home Manager Options](https://home-manager-options.extranix.com/)
            - [devenv Documentation](https://devenv.sh/)
            - [flake-parts Documentation](https://flake.parts/)

            ---

            ## Dendritic Pure-Leaf Architecture

            Every feature in [`modules/aspects/`](modules/aspects) is organized as an atomic **leaf aspect** under `den.aspects.*`. Leaf aspects encapsulate their own NixOS, Home Manager, nixpkgs overlay, and impermanence persistence configurations in a single file, and are selectively composed by **roles** (`den.aspects.roles.*`) consumed by hosts:

            ```text
            modules/
            ├── aspects/
            │   ├── applications/
            │   │   ├── browsers/        # zen, firefox, librewolf, chromium, tor-browser, _common/
            │   │   ├── dev/
            │   │   │   ├── ai/          # llm-agents, opencode, pi, antigravity, copilot
            │   │   │   ├── editor/      # neovim, helix, vim, lazyvim, doom-emacs, vscode, zed
            │   │   │   ├── git/         # git, github, lazygit
            │   │   │   ├── lang/        # go, rust, node, elixir, lua, nix, cc
            │   │   │   ├── mux/         # tmux, zellij, sesh, workmux, herdr
            │   │   │   ├── networking/  # winbox, wireguard, mtr, doggo
            │   │   │   ├── security/    # bitwarden, gpg, ssh, sops
            │   │   │   └── shell/       # direnv, mise, television, starship, zoxide, fzf, bat, btop, vivid, fastfetch, tealdeer
            │   │   ├── gaming/          # steam, mangohud, gamescope, gamemode, lutris, heroic, bottles, nix-ld
            │   │   ├── media/           # mpv, vlc, rmpd, cava, yt-dlp, imv, feh, mpvpaper
            │   │   ├── messaging/       # vesktop
            │   │   ├── productivity/    # tuxedo, evince, foliate, galculator, zennotes, torlink, localsend, anydesk, scrcpy
            │   │   ├── shell/           # zsh, fish, carapace, yazi, superfile, cli-utils
            │   │   ├── terminals/       # ghostty, kitty, foot
            │   │   └── wayland/         # wl-kbptr, fuzzel, cliphist, quickshell, fcitx5
            │   ├── core/                # boot, documentation, locale, mounts, networking, nh, nix, nixpkgs, security, users
            │   ├── desktop/             # audio, dms, fonts, greeter, gtk, hyprland, kdeconnect, mangowm, nautilus, niri, noctalia, stylix, thunar, udiskie, xdg, xserver
            │   ├── disk/                # btrfs (Disko layout)
            │   ├── hardware/            # bluetooth, graphics, input, nixos, power, steam-hardware
            │   ├── roles/               # default, workstation, dev, gaming
            │   ├── secrets/             # agenix
            │   ├── services/            # avahi, openssh, printing, samba, smartd, tailscale
            │   └── virtualization/      # libvirt, podman, waydroid
            ├── classes/                 # devenv, files, nix-unit, treefmt
            ├── core/                    # capabilities, impermanence, policies, quirks, settings
            ├── flake-parts/             # devenv, files, flake-file, flake-root, formatter, meta, pkgs, wrappers
            ├── hosts/                   # nixos, super, sandbox
            └── users/                   # artifex
            ```

            ---

            ## Topology & Hosts

            Hosts and user topologies are declared in [`modules/hosts/`](modules/hosts):

            | Host | Architecture | User | Roles & Aspects |
            |------|--------------|------|-----------------|
            | **`nixos`** | `x86_64-linux` | `artifex` | `roles.default`, `roles.workstation`, `roles.dev`, `roles.gaming`, `hardware.nixos`, `secrets.agenix` |
            | **`super`** | `x86_64-linux` | `artifex` | `roles.default`, `roles.workstation`, `roles.dev`, `roles.gaming`, `disk.btrfs`, `impermanence`, `secrets.agenix` |
            | **`sandbox`** | `x86_64-linux` | `artifex` | `roles.default`, `applications.gaming.nix-ld` (Isolated testbed host for rapid VM testing) |

            ---

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

            The environment provides tools like `age`, `agenix`, `secretspec`, `just`, `git`, `gh`, `nix-output-monitor`, `nix-fast-build`, and `treefmt`.

            ---

            ## System Deployment (`nh`)

            Deploy system configurations safely using [`nh`](https://github.com/viperML/nh):

            ```bash
            # Build toplevel derivation
            nix run .#os -- build

            # Switch current machine to host 'nixos'
            nix run .#os -- switch --target nixos

            # Switch current machine to host 'super'
            nix run .#os -- switch --target super

            # Test configuration without adding boot entry
            nix run .#os -- test
            ```

            ---

            ## VM Testing Suite

            Test configurations in isolated QEMU virtual machines before deploying to bare metal. Configured in [`modules/vm.nix`](modules/vm.nix).

            ### VM Runners

            ```bash
            # Run default VM runner
            nix run .#vm

            # Run host 'nixos' in a VM
            nix run .#vm-nixos

            # Run host 'super' in a VM
            nix run .#vm-super

            # Run isolated sandbox host in a VM
            nix run .#vm-sandbox
            ```

            ### Remote SSH Access into VM

            Every running VM forwards host port `2222` to the guest's SSH daemon (`22`):

            ```bash
            ssh -p 2222 artifex@localhost
            # Default VM password: 12345
            ```

            ---

            ## Secrets Management (`agenix-rekey`)

            Secrets are encrypted with age keys and rekeyed per host/user using `agenix-rekey`:

            - **Master identity:** `.secrets/master.age`
            - **Host public keys:** `.secrets/hosts/*.pub`
            - **Rekeyed ciphertext:** `.secrets/rekeyed/<host>/` and `.secrets/rekeyed/<user>/`

            ### Rekeying Secrets

            When modifying secret sources or adding a new host key:

            ```bash
            # Rekey all secrets for all declared hosts and users
            agenix rekey -a
            ```

            ---

            ## Code Formatting & Flake Maintenance

            - **Format all code:**
              ```bash
              treefmt
              ```
            - **Regenerate `flake.nix`:**
              ```bash
              nix run .#write-flake
              ```
            - **Run all flake checks:**
              ```bash
              nix flake check --no-build
              ```
          '';
      };
    };
  };
}
