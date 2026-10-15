# Den Dotfiles Configuration

A modern, aspect-oriented NixOS and Home Manager configuration powered by [Den](https://den.denful.dev), [flake-file](https://github.com/denful/flake-file), [devenv](https://devenv.sh), and [agenix-rekey](https://github.com/oddlama/agenix-rekey).

---

## Quick Links

- [Den Documentation](https://den.denful.dev)
- [NixOS Options Search](https://search.nixos.org/options?channel=unstable)
- [Home Manager Options](https://home-manager-options.extranix.com/)
- [devenv Documentation](https://devenv.sh/)
- [flake-parts Documentation](https://flake.parts/)

---

## Topology & Hosts

Hosts and user topologies are declared in [`modules/hosts.nix`](modules/hosts.nix):

| Host | Architecture | User | Role |
|------|--------------|------|------|
| **`nixos`** | `x86_64-linux` | `artifex` | Primary workstation (Disko Btrfs, Impermanence, Secrets) |
| **`super`** | `x86_64-linux` | `artifex` | High-performance host profile (Disko Btrfs, Impermanence, Secrets) |
| **`sandbox`** | `x86_64-linux` | `artifex` | Isolated testbed host for rapid VM testing without physical disks |

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
