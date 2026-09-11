# [lsd.nix](https://github.com/nix-community/home-manager/blob/master/modules/programs/lsd.nix)
# [lsd.options](https://search.nixos.org/options?channel=unstable&query=programs.lsd&source=home_manager&type=options)
{
  den.default.homeManager.programs.lsd = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };
}
