# BOOTSTRAP.md — New Machine Installation Guide

This guide walks through bootstrapping and installing this Den-based NixOS configuration on a new machine from scratch: preparing the live installer, cloning the repository, assigning disks and Btrfs subvolumes (for `/persist` and `/cache` impermanence), creating `modules/hosts/<new-machine>.nix`, selecting roles and hardware aspects, provisioning secrets, and completing the installation.

> **Note:** `BOOTSTRAP.md` is a generated file managed via [`modules/flake-parts/files/bootstrap.nix`](modules/flake-parts/files/bootstrap.nix). Run `nix run .#write-files` after modifying its source module.

## 1. Live Installer & Network Setup

1. Boot the target machine from a **NixOS Minimal or Graphical ISO** in **UEFI mode** (`/sys/firmware/efi` must exist).
2. Connect to the network:
   ```bash
   # Wi-Fi / Ethernet via NetworkManager TUI
   sudo systemctl start NetworkManager
   nmtui
   ```
3. Enter a shell with `git`, `vim`, and `disko` available:
   ```bash
   nix-shell -p git neovim
   ```

## 2. Cloning the Repository

Clone the repository into `/tmp/dotfiles` inside the live environment (you will also copy it into the target user's `~/.dotfiles` before rebooting):

```bash
git clone https://github.com/artifex/.dotfiles.git /tmp/dotfiles
cd /tmp/dotfiles
```

## 3. Assigning Disks & Btrfs Subvolumes

This configuration uses an **ephemeral Btrfs root (`/`)** with dedicated subvolumes for `/nix`, `/home`, `/persist`, and `/cache`, plus a read-only `/root-blank` snapshot used by `den.aspects.impermanence.rollback-btrfs` on boot.

### Step 3.1: Identify the Target Disk
List available block devices and find the stable disk path or UUID:
```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,LABEL,UUID,MODEL
ls -l /dev/disk/by-id/
```

### Step 3.2: Option A — Declarative Partitioning with Disko (Recommended)
The aspect [`modules/aspects/disk/btrfs.nix`](modules/aspects/disk/btrfs.nix) (`den.aspects.disk.btrfs`) declaratively creates:
- **ESP (`/boot`)**: `1G` `vfat` EFI System Partition
- **Swap**: `8G` swap partition
- **Root Btrfs partition (`-L nixos`)**:
  - `/root` → mounted at `/` (rolled back to `/root-blank` on every boot)
  - `/root-blank` → read-only initial snapshot created automatically by `postCreateHook`
  - `/nix` → mounted at `/nix` (`neededForBoot = true`)
  - `/home` → mounted at `/home` (`neededForBoot = true`)
  - `/persist` → mounted at `/persist` (`neededForBoot = true`)
  - `/cache` → mounted at `/cache` (`neededForBoot = true`)

To assign your target disk to a host using `disk.btrfs`, override `disko.devices.disk.main.device` in your host module (`modules/hosts/<new-machine>.nix`):
```nix
nixos = {
  disko.devices.disk.main.device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_1TB_XXXX";
};
```

### Step 3.3: Option B — Custom or Multi-Disk Hardware Layout
If your machine has a custom partition layout or existing filesystems (like `modules/hosts/nixos/hardware.nix`), generate a hardware scan and place the hardware configuration under `modules/hosts/<new-machine>/hardware.nix`:
```bash
nixos-generate-config --root /mnt --show-hardware-config
```
Wrap the generated config in a leaf aspect under `modules/hosts/<new-machine>/hardware.nix`:
```nix
# Hardware Configuration for Host "<new-machine>"
{
  den.aspects.hardware.<new-machine> = {
    nixos =
      { config, lib, modulesPath, ... }:
      {
        imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

        boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
        boot.kernelModules = [ "kvm-intel" ]; # or "kvm-amd"

        fileSystems."/" = {
          device = "/dev/disk/by-label/nixos";
          fsType = "btrfs";
          options = [ "subvol=root" "compress=zstd" "noatime" ];
        };

        fileSystems."/boot" = {
          device = "/dev/disk/by-uuid/<BOOT-UUID>";
          fsType = "vfat";
          options = [ "fmask=0077" "dmask=0077" ];
        };

        fileSystems."/nix" = {
          device = "/dev/disk/by-label/nixos";
          fsType = "btrfs";
          options = [ "subvol=nix" "compress=zstd" "noatime" ];
          neededForBoot = true;
        };

        fileSystems."/home" = {
          device = "/dev/disk/by-label/nixos";
          fsType = "btrfs";
          options = [ "subvol=home" "compress=zstd" "noatime" ];
          neededForBoot = true;
        };

        fileSystems."/persist" = {
          device = "/dev/disk/by-label/nixos";
          fsType = "btrfs";
          options = [ "subvol=persist" "compress=zstd" "noatime" ];
          neededForBoot = true;
        };

        fileSystems."/cache" = {
          device = "/dev/disk/by-label/nixos";
          fsType = "btrfs";
          options = [ "subvol=cache" "compress=zstd" "noatime" ];
          neededForBoot = true;
        };
      };
  };
}
```
*(If partitioning manually without Disko, ensure the Btrfs filesystem is labeled `nixos` via `mkfs.btrfs -L nixos` and that a read-only snapshot `btrfs subvolume snapshot -r /mnt/root /mnt/root-blank` is created before first reboot.)*

## 4. Creating `modules/hosts/<new-machine>.nix`

Every host in this repository is defined by a single file in [`modules/hosts/`](modules/hosts) (for example, `modules/hosts/new-machine.nix`). Because `import-tree` auto-discovers all `.nix` files under `modules/`, no manual import list is required.

### Complete Example: `modules/hosts/new-machine.nix`

```nix
# Host "new-machine": Primary Workstation / Laptop
{
  den,
  ...
}:
{
  # 1. Define the host aspect (roles, hardware, disk, persistence, and OS overrides)
  den.aspects.new-machine = {
    includes = with den.aspects; [
      # High-level roles
      roles.default
      roles.workstation
      roles.dev
      roles.gaming

      # Disk layout & Impermanence
      disk.btrfs
      impermanence

      # Hardware profile (e.g., hardware.laptop, hardware.graphics.amd, or hardware.new-machine)
      # hardware.laptop
      # hardware.graphics.amd

      # Secrets & VM testing support
      secrets.agenix
      virtualization.vm-variant
      (den.batteries.vm-autologin "artifex")
    ];

    nixos =
      { lib, pkgs, ... }:
      {
        # Assign target disk for Disko
        disko.devices.disk.main.device = "/dev/disk/by-id/nvme-YOUR_DISK_ID";

        boot.initrd.availableKernelModules = [
          "xhci_pci"
          "ahci"
          "nvme"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];

        boot.kernelModules = [ "kvm-intel" ]; # or "kvm-amd"
        boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
        boot.loader.systemd-boot.enable = lib.mkDefault true;

        environment.systemPackages = with pkgs; [
          git
          vim
          curl
          wget
        ];

        networking.hostName = "new-machine";
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

        # Point OpenSSH host keys directly to persistent storage
        services.openssh.hostKeys = [
          {
            path = "/persist/etc/ssh/ssh_host_ed25519_key";
            type = "ed25519";
          }
          {
            bits = 4096;
            path = "/persist/etc/ssh/ssh_host_rsa_key";
            type = "rsa";
          }
        ];
      };

    description = "New Machine Workstation";
    isWorkstation = true;

    # Optional per-host Home Manager packages or overrides projected to users on this host
    provides.to-users.homeManager = _: {
      home.packages = [ ];
    };
  };

  # 2. Register the host entity in Den under its architecture
  den.hosts.x86_64-linux.new-machine = {
    description = "New Machine Workstation";
    isWorkstation = true;

    # Attach declared user(s) to this host
    users.artifex = { };

    # Optional per-aspect typed settings
    settings = {
      impermanence = {
        wipeRootOnBoot = true;
        wipeHomeOnBoot = false;
      };
      # desktop.hyprland.cardDevice = "/dev/dri/card1:/dev/dri/card0";
    };
  };
}
```

After creating `modules/hosts/new-machine.nix` (and `modules/hosts/new-machine/hardware.nix` if using Option B), **stage the file(s) in Git** so Nix flake evaluation can see them:
```bash
git add -N modules/hosts/new-machine.nix
# If using custom hardware:
# git add -N modules/hosts/new-machine/hardware.nix
```

## 5. Choosing Roles & Aspects

Mix and match roles and leaf aspects inside `den.aspects.<new-machine>.includes` based on the machine's purpose:

### Core Roles (`modules/aspects/roles/`)

| Role | When to Include | Included Capabilities |
| :--- | :--- | :--- |
| **`roles.default`** | **Always** (all hosts, servers & workstations) | Bootloader (`systemd-boot`), locale, networking (`NetworkManager`, firewall), Nix daemon & binary caches, `nh`, security (`sudo`, `polkit`, `pam`), base hardware (`bluetooth`, `graphics`, `input`, `power`), services (`avahi`, `openssh`, `printing`, `samba`, `smartd`, `tailscale`), and core shell (`zsh`, `carapace`, `cli-utils`). |
| **`roles.workstation`** | Interactive GUI desktops & laptops | Wayland compositors (`hyprland`, `niri`, `mangowm`, `dms`, `greeter`), PipeWire audio, Stylix theming, GTK/XDG portals, file managers (`nautilus`, `thunar`, `udiskie`), browsers (`zen`, `firefox`, `librewolf`, `chromium`, `tor-browser`), terminals (`ghostty`, `kitty`, `foot`), Wayland utilities (`fuzzel`, `cliphist`, `fcitx5`, `wl-kbptr`), media/messaging (`mpv`, `vlc`, `rmpd`, `vesktop`), productivity apps (`obsidian`, `foliate`, `evince`, `localsend`, `anydesk`), and virtualization (`libvirt`, `podman`, `waydroid`). |
| **`roles.dev`** | Developer workstations | Editors (`neovim`, `neovim-mdkite`, `neovim-org`, `codium`, `helix`, `vim`, `doom-emacs`, `zed`), AI coding agents (`llm-agents`, `opencode`, `pi`, `antigravity`, `copilot`, `mcp`), Git & GitHub CLI (`git`, `github`, `lazygit`), multiplexers (`tmux`, `zellij`, `sesh`, `workmux`, `herdr`), language toolchains (`go`, `rust`, `node`, `elixir`, `lua`, `nix`, `python`, `cc`, `shell`, `markdown`, `data`, `kdl`, `grammars`), dev tools (`mise`, `direnv`, `devenv`, `treefmt`, `sqlite`), security (`bitwarden`, `gpg`, `ssh`, `sops`), and CLI/TUI tools (`television`, `starship`, `zoxide`, `fzf`, `bat`, `btop`, `yazi`, `superfile`). |
| **`roles.gaming`** | Gaming machines | `hardware.steam-hardware`, `nix-ld`, `steam`, `mangohud`, `gamescope`, `gamemode`, `lutris`, `heroic`, `bottles`. |

### Hardware, Storage & System Aspects

| Aspect | Purpose |
| :--- | :--- |
| **`disk.btrfs`** | Declarative Disko GPT + Btrfs subvolume layout (`/root`, `/root-blank`, `/nix`, `/home`, `/persist`, `/cache`). |
| **`impermanence`** | Btrfs root rollback on boot (`impermanence.rollback-btrfs`), `/tmp` on tmpfs (`impermanence.tmpfs`), and `/persist` + `/cache` bind-mount collector (`impermanence.collect`). |
| **`secrets.agenix`** | System and Home Manager secret decryption with `agenix` and `agenix-rekey`. |
| **`hardware.laptop`** | Laptop-specific power management, battery thresholds, and thermal tuning. |
| **`hardware.graphics.amd`** | AMD GPU drivers, Vulkan/ROCm acceleration, and `amdgpu` kernel module setup. |
| **`hardware.graphics.intel`** | Intel integrated/discrete GPU VA-API and Vulkan acceleration. |
| **`hardware.graphics.nvidia`** | NVIDIA proprietary/open kernel module drivers and Wayland modesetting. |
| **`hardware.graphics.nvidia-prime`** | Hybrid Intel/AMD + NVIDIA Optimus PRIME offload configuration. |
| **`hardware.graphics.amd-vfio`** / **`nvidia-vfio`** | PCIe GPU passthrough (VFIO/IOMMU) for Windows gaming VMs (`virtualization.windows-vm` & `looking-glass`). |
| **`virtualization.vm-variant`** | QEMU test VM overrides (`nixos-rebuild build-vm`) with automatic `/persist` and `/cache` tmpfs mounts. |

### Minimal Headless / Server / Sandbox Host Example
For a lightweight headless machine or testbed (like `modules/hosts/sandbox.nix`), include only `roles.default` and specific leaf aspects:
```nix
den.aspects.my-server = {
  includes = with den.aspects; [
    roles.default
    disk.btrfs
    impermanence
    secrets.agenix
  ];
  isServer = true;
  isWorkstation = false;
};
```

## 6. Users & Secrets (`agenix-rekey`)

### Using or Adding a User
- To use the primary account `artifex` ([`modules/users/artifex.nix`](modules/users/artifex.nix)), set `users.artifex = { };` inside `den.hosts.x86_64-linux.<new-machine>`.
- If `.secrets/users/artifex/password.age` is not present or not yet rekeyed for the new host, the account falls back to `initialPassword = "12345"` so you can log in on first boot.
- To create a new user `<username>`, create `modules/users/<username>.nix` modeled after `modules/users/artifex.nix` (`den.batteries.host-aspects`, `den.batteries.primary-user`, `(den.batteries.user-shell "zsh")`) and reference `users.<username> = { };` in your host.

### Provisioning SSH Host Keys & Agenix Rekeying
Because `secrets.agenix` decrypts host secrets using `/persist/etc/ssh/ssh_host_ed25519_key`:
1. After mounting the target filesystems at `/mnt` (Step 7.1 below), generate the host SSH key directly on `/mnt/persist`:
   ```bash
   sudo mkdir -p /mnt/persist/etc/ssh
   sudo ssh-keygen -t ed25519 -N "" -f /mnt/persist/etc/ssh/ssh_host_ed25519_key
   sudo ssh-keygen -t rsa -b 4096 -N "" -f /mnt/persist/etc/ssh/ssh_host_rsa_key
   ```
2. Copy the new host's public key into the repository for `agenix-rekey`:
   ```bash
   cp /mnt/persist/etc/ssh/ssh_host_ed25519_key.pub .secrets/hosts/<new-machine>.pub
   git add .secrets/hosts/<new-machine>.pub
   ```
3. On a machine with access to the master Age identity (or after unlocking `.secrets/master.age`), rekey secrets for the new host:
   ```bash
   agenix rekey
   git add .secrets/rekeyed/<new-machine>
   ```
   *(Note: `modules/aspects/secrets/agenix.nix` gracefully falls back if `.secrets/hosts/<new-machine>.pub` does not exist yet during initial bootstrap.)*

## 7. Partitioning, Installing & First Boot

### Step 7.1: Partition and Mount with Disko
From `/tmp/dotfiles`, run Disko for your new host to partition, format Btrfs subvolumes, create `/root-blank`, and mount everything under `/mnt`:
```bash
sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- \
  --mode destroy,format,mount \
  --flake .#<new-machine>
```

### Step 7.2: Place the Dotfiles Repository into Persistent Home Storage
Out-of-store config symlinks (`config.lib.dots.link` backed by `user.dotsConfigPath`) and `impermanence` (`persistHome.directories = [ ".dotfiles" ]`) expect the repository at `/persist/home/artifex/.dotfiles` (bind-mounted to `/home/artifex/.dotfiles`):
```bash
sudo mkdir -p /mnt/persist/home/artifex /mnt/home/artifex /mnt/cache/home/artifex
sudo cp -a /tmp/dotfiles /mnt/persist/home/artifex/.dotfiles
sudo chown -R 1000:100 /mnt/persist/home/artifex /mnt/home/artifex /mnt/cache/home/artifex
```

### Step 7.3: Verify Evaluation & Run `nixos-install`
```bash
# Verify the host configuration evaluates cleanly
nix eval .#nixosConfigurations.<new-machine>.config.system.build.toplevel.drvPath

# Install NixOS for <new-machine>
sudo nixos-install --flake .#<new-machine> --no-root-passwd
```

### Step 7.4: Reboot & Post-Install Verification
```bash
sudo reboot
```
After logging in on the new machine:
```bash
cd ~/.dotfiles

# 1. Activate the developer shell
direnv allow

# 2. Synchronize generated files and topology documentation
nix run .#write-flake
nix run .#write-files
nix run .#diagrams.write-topology

# 3. Test a labeled rebuild switch
rebuild-switch
```
