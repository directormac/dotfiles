# [vim.nix](https://github.com/nix-community/home-manager/blob/master/modules/programs/vim.nix)
# [vim.plugins](https://search.nixos.org/options?channel=unstable&query=programs.vim&source=home_manager&type=options#show=home-manager-option%253Aprograms.vim.plugins)
# [vim.settings](https://search.nixos.org/options?channel=unstable&query=programs.vim&source=home_manager&type=options#show=home-manager-option%253Aprograms.vim.settings)
{
  # [plugins search](https://search.nixos.org/packages?channel=unstable&query=vimPlugins&source=home_manager)
  den.default.homeManager.programs.vim = {
    enable = true;
    defaultEditor = true;
  };
}
