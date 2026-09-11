# [yazi.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/programs/yazi.nix)
# [yazi.options](https://search.nixos.org/options?channel=unstable&query=programs.yazi&type=options)
{
  den.default.homeManager.programs.yazi = {
    enable = true;
    shellWrapperName = "y";
  };
}
