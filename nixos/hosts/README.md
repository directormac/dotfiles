# Host Configurations

This directory contains host-specific configurations for the Dendritic NixOS setup. Each directory here represents a distinct physical or virtual machine.

## How to Add and Deploy a New Host

To create a new host (e.g., `my-new-host`), you'll need to define three files in a new directory under `nixos/hosts/my-new-host/`:

1. `hardware.nix`
2. `configuration.nix`
3. `default.nix`

### Approach 1: Fresh Install from a NixOS Live USB (Direct Flake Install)

If you are formatting a new machine and want to install your custom setup straight from the Live USB:

1. **Boot and Prepare:** Boot the NixOS Live USB, connect to the internet, partition your drives, and mount root to `/mnt` (and boot to `/mnt/boot`).
2. **Clone Dotfiles:** Clone your dotfiles into the Live USB's RAM disk:

   ```bash
   git clone https://github.com/yourusername/dotfiles.git /tmp/dotfiles
   cd /tmp/dotfiles
   ```

3. **Generate Hardware Config:**

   ```bash
   nixos-generate-config --root /mnt --dir /tmp/dotfiles/nixos/hosts/my-new-host
   ```

4. **Setup `hardware.nix`:** Rename the generated `hardware-configuration.nix` to `hardware.nix` and wrap it to export a flake module:

   ```nix
   { self, inputs, ... }: {
     flake.nixosModules.myNewHostHardware =
       { config, lib, pkgs, modulesPath, ... }:
       {
         # --- PASTE THE GENERATED IMPORTS AND CONFIGURATION HERE ---
         imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
         # ...
       };
   }
   ```

5. **Setup `configuration.nix`:** Create `configuration.nix` combining the hardware module and any features:

   ```nix
   { self, inputs, ... }: {
     flake.nixosModules.myNewHostConfiguration = { pkgs, lib, config, ... }: {
       imports = [
         self.nixosModules.myNewHostHardware
         # Include your shared features here
         self.nixosModules.niri
         self.nixosModules.sddm
       ];

       networking.hostName = "my-new-host";
       boot.loader.systemd-boot.enable = true;
       boot.loader.efi.canTouchEfiVariables = true;
       system.stateVersion = "25.05"; # Match the current state version
     };
   }
   ```

6. **Setup `default.nix`:** Stitch it all together to expose the flake output:

   ```nix
   { self, inputs, ... }: {
     flake.nixosConfigurations.my-new-host = inputs.nixpkgs.lib.nixosSystem {
       modules = [
         inputs.home-manager.nixosModules.default
         self.nixosModules.myNewHostConfiguration
       ];
     };
   }
   ```

7. **Git Add:** Nix flakes ignore untracked files!

   ```bash
   git add nixos/hosts/my-new-host
   ```

8. **Install:**

   ```bash
   nixos-install --flake /tmp/dotfiles#my-new-host --root /mnt
   ```

9. **Reboot!** Once you've booted into your new machine, clone your dotfiles into their permanent location (`~/.dotfiles`).

### Approach 2: The "Vanilla First" Method

If editing files on the Live USB is too cumbersome, do a basic vanilla install first:

1. Partition, mount to `/mnt`, and run `nixos-generate-config --root /mnt`.
2. Run `nixos-install` (no flake arguments).
3. Reboot into the basic NixOS console.
4. Clone your dotfiles repo to `~/.dotfiles`.
5. Copy `/etc/nixos/hardware-configuration.nix` into `~/.dotfiles/nixos/hosts/my-new-host/hardware.nix` and format it as shown in step 4 above.
6. Create your `configuration.nix` and `default.nix`.
7. Add files to git: `git add nixos/hosts/my-new-host`.
8. Apply the flake:

   ```bash
   sudo nixos-rebuild switch --flake ~/.dotfiles#my-new-host
   ```
