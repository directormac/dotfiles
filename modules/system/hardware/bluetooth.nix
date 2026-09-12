{
  /**
  [bluetooth.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/hardware/bluetooth.nix)
  [options](https://search.nixos.org/options?channel=unstable&query=bluetooth+&type=options#show=option%253Ahardware.bluetooth.enable)
  */
  den.ful.hardware.bluetooth = {
    nixos.hardware.bluetooth.enable = true;
  };
}
