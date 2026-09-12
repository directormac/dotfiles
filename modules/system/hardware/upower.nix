{
  /**
  [upower.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/hardware/upower.nix)
  [upwer](https://upower.freedesktop.org/)
  */
  den.ful.hardware.upower = {
    nixos.services.upower.enable = true;
  };
}
