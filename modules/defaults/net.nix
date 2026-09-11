# [networking.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/networking/)
# [networking.options](https://search.nixos.org/options?channel=unstable&query=networking&type=options)
{den, ...}: {
  den.default.nixos.networking.networkmanager.enable = true;
  den.default.includes = [den.batteries.hostname];
}
