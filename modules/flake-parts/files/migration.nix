{
  config,
  lib,
  dag,
  ...
}:
{
  options.flake.migration = lib.mkOption {
    default = { };
    description = "DAG of sections to assemble into MIGRATION.md";
    type = lib.types.lazyAttrsOf lib.types.unspecified;
  };

  config = {
    flake.migration.after-boot =
      dag.entryBetween [ "rollback" ] [ "procedure" ]
        # markdown
        ''
          ## 5. Verify on `super`

          ```bash
          hostnamectl --static                              # super
          findmnt -o TARGET,SOURCE,OPTIONS / /nix /home /persist /cache /boot
          sudo btrfs subvolume list / | grep -E 'root-blank|root$'
          swapon --show                                     # the 8G partition on the NVMe
          sudo journalctl -b | grep -E 'rollback-root|Roll the root'   # wipe actually ran
          ls /etc/ssh/ssh_host_*; ls /run/agenix            # secrets decrypted with the carried host key
          tailscale status; ls ~/.ssh ~/.dotfiles | head
          findmnt /mnt/local/resources                      # NTFS Resources disk
          ```

          Prove the rollback and the persistence split with a canary:

          ```bash
          sudo touch /root/canary /persist/canary && sudo reboot
          # after boot:
          ls /root/canary      # must be gone
          ls /persist/canary   # must still exist
          sudo rm /persist/canary
          ```

          Then check the things that broke before on impermanence: browser sessions stay logged in, tmux sessions restore, `nvim` formats on save, DMS/Hyprland start on the correct GPU (`settings.desktop.hyprland.cardDevice` in `modules/hosts/super.nix`).

          Finally switch once from the repository so the generation gets a proper label (user action, never run by an agent):

          ```bash
          cd ~/.dotfiles && rebuild-switch
          ```

          ### Optional clean-ups after a stable week

          - Give `super` its own secret recipient entry: `cp .secrets/hosts/nixos.pub .secrets/hosts/super.pub && agenix rekey && git add .secrets`. The key is identical, so this only removes the `nixos` fallback in `modules/aspects/secrets/agenix.nix`.
          - Remove the `nixos` host (`modules/hosts/nixos.nix`, `modules/hosts/nixos/`, `hardware.nixos`) once `sda` is retired, then run the generators from `AGENTS.md`.
          - Reuse `sda` only after you no longer need the fallback: `nix-flake-build super`, boot it for a week, then wipe it.
        '';

    flake.migration.header =
      dag.entryBefore [ "state" ]
        # markdown
        ''
          # MIGRATION.md — Moving the running `nixos` install to the `super` NVMe

          > **Note:** `MIGRATION.md` is a generated file managed via [`modules/flake-parts/files/migration.nix`](modules/flake-parts/files/migration.nix). Edit that module and run `nix run .#write-files`.

          Goal: re-create the current system on the NVMe (`nvme0n1`, Samsung 980 PRO 1TB) as host **`super`**, keep every byte of persisted state (`/persist`, `/cache`, `/home`), and keep the old SATA SSD (`sda`) untouched as a fallback until `super` is proven.

          **Can the disk be formatted from the live system?** Yes, the NVMe — it is not mounted and nothing running uses it. Disko's script only touches the by-id device in `settings.disk.btrfs.device`. The running root disk (`sda`) can **not** be formatted until you boot from the NVMe. You never need to.
        '';

    flake.migration.procedure =
      dag.entryBetween [ "after-boot" ] [ "state" ]
        # markdown
        ''
          ## 1. Preparation (as `artifex`, in `~/.dotfiles`)

          ```bash
          # Commit or at least stage everything; the copy in step 3 carries the repo along
          git add -N modules/ pkgs/ && git status --short

          # Inspect what is on the NVMe now. Wiping it is irreversible.
          lsblk -f /dev/nvme0n1
          sudo mkdir -p /tmp/nvme-old && sudo mount -o ro /dev/nvme0n1p2 /tmp/nvme-old
          ls -la /tmp/nvme-old; sudo umount /tmp/nvme-old

          # The host key and machine-id that must survive
          sudo ls -l /persist/etc/ssh/ssh_host_ed25519_key /persist/etc/machine-id
          ```

          **Audit state that is *not* persisted yet.** Because root was never wiped, services may have grown dependencies on unpersisted paths. Candidates seen on this machine: `/root/.ssh`, `/var/lib/private` (systemd `DynamicUser` services), `/var/lib/cups/printers.conf` (printers), `/var/lib/AccountsService` (login icon/session), `/var/lib/misc`. For each one you care about, add it to the matching quirk (`persist.directories`, `persistHome.directories`, ...) in the aspect that owns the service **before** you copy, then rebuild. Anything under `/home` that is not a bind mount is safe: the whole `home` subvolume is copied and `wipeHomeOnBoot` is `false`.

          ```bash
          # Paths that are already bind-mounted from /persist or /cache
          findmnt -rn -o TARGET,SOURCE | grep -E '\[/(persist|cache)/' | awk '{print $1}' | sort
          # Top-level state directories that are NOT in that list
          sudo ls /root /var/lib /etc
          ```

          ## 2. Build, then partition and format the NVMe

          Build as your own user so root never has to read the git repo (avoids `dubious ownership` errors) and the closure lands in the running store:

          ```bash
          nix build -o /tmp/super-system .#nixosConfigurations.super.config.system.build.toplevel
          nix build -o /tmp/super-disko  .#nixosConfigurations.super.config.system.build.diskoScript

          # Safety check: this must list ONLY the NVMe by-id path and nothing from sda
          grep -o '/dev/disk/by-id/[^ ;")]*' /tmp/super-disko | sort -u
          grep -c dcd3cd20 /tmp/super-disko   # must print 0 (sda2 UUID)
          ```

          Run it (destroys the NVMe, creates the layout, creates `root-blank`, mounts everything under `/mnt`). Use the **resolved store path**: `/tmp` has `fs.protected_symlinks` enabled, so root refuses to follow a symlink in `/tmp` owned by your user and `sudo /tmp/super-disko` fails with `command not found`.

          ```bash
          sudo "$(readlink -f /tmp/super-disko)"
          findmnt -R /mnt
          sudo btrfs subvolume list /mnt      # cache, home, nix, persist, root, root-blank
          ```

          ## 3. Copy the persistent data (two passes)

          The old `home` subvolume is mounted a second time because bind mounts shadow `/home/artifex/*` on the running system. It is only read from (no `ro` flag: btrfs may refuse a read-only mount of a filesystem that is already mounted read-write).

          ```bash
          sudo mkdir -p /run/sda-home
          sudo mount -o subvol=home /dev/disk/by-label/root /run/sda-home

          # Pass 1: live, keep working while it runs (~110G)
          for s in /persist/:/mnt/persist/ /cache/:/mnt/cache/ /run/sda-home/:/mnt/home/; do
            sudo rsync -aHAXx --numeric-ids --info=progress2 "''${s%%:*}" "''${s##*:}"
          done
          ```

          Pass 2: quiesce writers, then sync the delta. Log out of the graphical session, switch to a TTY, log in, and:

          ```bash
          sudo systemctl stop display-manager libvirtd tailscaled bluetooth
          for s in /persist/:/mnt/persist/ /cache/:/mnt/cache/ /run/sda-home/:/mnt/home/; do
            sudo rsync -aHAXx --numeric-ids --delete --info=progress2 "''${s%%:*}" "''${s##*:}"
          done
          sudo umount /run/sda-home

          # Identity must be byte-identical on the target
          sudo cmp /persist/etc/ssh/ssh_host_ed25519_key /mnt/persist/etc/ssh/ssh_host_ed25519_key && echo key ok
          sudo cmp /persist/etc/machine-id /mnt/persist/etc/machine-id && echo machine-id ok
          ls -ld /mnt/persist/home/artifex /mnt/home/artifex   # owner artifex:users (1000:100)
          ```

          The repository travels inside `/persist/home/artifex/.dotfiles`, so it must be committed/staged **before** pass 2.

          ## 4. Install

          ```bash
          sudo nixos-install --root /mnt --system "$(readlink -f /tmp/super-system)" --no-root-passwd
          ```

          This copies the `super` closure from the running store into `/mnt/nix/store` and installs systemd-boot on the new ESP (`canTouchEfiVariables = true` registers a firmware entry). The old ESP on `sda` is left alone, so the firmware now has two boot managers. Passwords come from the same declarative source as today (`modules/users/artifex.nix`: agenix `password.age` or the `initialPassword` fallback).

          ```bash
          sudo umount -R /mnt
          sudo reboot
          ```

          In the firmware boot menu pick the **NVMe** entry (`Linux Boot Manager`). If it is ambiguous, pick by disk name; the `sda` entry still boots the old `nixos` install.
        '';

    flake.migration.rollback =
      dag.entryAfter [ "after-boot" ]
        # markdown
        ''
          ## 6. If something goes wrong

          | Symptom | Action |
          | :--- | :--- |
          | `super` does not boot | Pick the `sda` entry in the firmware menu. The old install is unchanged. |
          | Missing file after the first boot | It lives on `sda`: boot `nixos`, copy it into `/persist/...`, and declare the path in a `persist*` quirk. |
          | Root not wiped (canary survives) | `ls -l /dev/disk/by-label/` must show `nixos` on the NVMe; the rollback service skips silently otherwise. |
          | Copy was interrupted or wrong | Re-run step 3; `rsync --delete` is idempotent. To start from scratch run `sudo "$(readlink -f /tmp/super-disko)"` again (destroys only the NVMe). |
          | `agenix` secrets missing | Compare `sha256sum /persist/etc/ssh/ssh_host_ed25519_key` with the `sda` copy and check `.secrets/hosts/nixos.pub` still matches it. |
        '';

    flake.migration.state =
      dag.entryBetween [ "procedure" ] [ "header" ]
        # markdown
        ''
          ## 0. What is actually running today

          | Fact | Consequence |
          | :--- | :--- |
          | Host is `nixos` on `sda` (`hardware.nixos`, [`modules/hosts/nixos/hardware.nix`](modules/hosts/nixos/hardware.nix)); `/` is the btrfs **top-level** (`subvolid=5`), only `home` and `nix` are subvolumes | `/persist` and `/cache` are **plain directories** on the root filesystem, not subvolumes |
          | `sda2` has label `root`, no `root-blank` snapshot | `rollback-root` ([`modules/core/impermanence.nix`](modules/core/impermanence.nix)) looks for `/dev/disk/by-label/nixos`, finds nothing and **exits 0**: **root has never been wiped on this machine** |
          | `super` includes `disk.btrfs` (label `nixos`, `root-blank`) | **On the first boot of `super` the wipe is real.** Anything outside `persist*` / `cache*` / the `/home` subvolume is gone after every reboot |
          | `agenix` decrypts with `/persist/etc/ssh/ssh_host_ed25519_key`; `.secrets/hosts/super.pub` does not exist | Falls back to `.secrets/hosts/nixos.pub` + `.secrets/rekeyed/nixos`. Works because the **same host key is copied over** |
          | `nvme0n1` already carries a 1G vfat + ~930G btrfs | Contents unknown to this repo: inspect before you wipe (step 1) |
          | `sdb1` (NTFS, `/mnt/local/resources`) | Not touched. Disko's script runs `umount -Rv /mnt`, which unmounts it (and the fileserver CIFS mount); reboot or `sudo mount -a` afterwards |

          Target layout (from [`modules/aspects/disk/btrfs.nix`](modules/aspects/disk/btrfs.nix)): 1G ESP (`/boot`), 8G swap, rest btrfs labelled `nixos` with subvolumes `root` (`/`), `root-blank`, `nix`, `home`, `persist`, `cache` (all `compress=zstd,noatime`).

          Data to move (measured on the running system): `/persist` ≈ 19G, `/cache` ≈ 86G, `home` subvolume ≈ 2G. `/nix` is **not** copied: `nixos-install --system` copies only the closure of `super` from the running store.
        '';

    perSystem = _: {
      files.file."MIGRATION.md".text = dag.render {
        entries = config.flake.migration;
        separator = "\n";
      };
    };
  };
}
