# NixOS configuration management shortcuts.
# Run `just` without arguments to see all available commands.

# List available commands
default:
    @just --list

# Apply the configuration to the current system (persists across reboots)
switch:
    sudo nixos-rebuild --flake . switch

# Test the configuration without making it the boot default
test:
    sudo nixos-rebuild --flake . test

# Update all flake inputs to their latest versions
update:
	nix run .#write-flake
	nix flake update

