# Deployment steps

[✅] [NixOS Cheatsheet](https://nixos.wiki/wiki/Cheatsheet)

## Installing to a new host

## Creating Bootable ISO

## Troubleshooting

### Delete a broken build

Run the commands on the working one

```sh
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
# Remove the target ID e.g 42
sudo nix-env --delete-generations ID --profile /nix/var/nix/profiles/system

# Clean up to update the boot menu
sudo nix-collect-garbage -d
sudo nixos-rebuild switch --flake .#hostname
```
