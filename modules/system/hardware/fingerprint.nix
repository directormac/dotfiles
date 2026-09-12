{
  /**
  [fprintd.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/security/fprintd.nix)
  */
  den.ful.hardware.fingerprint = {
    nixos.services.fprintd.enable = false;
  };
}
