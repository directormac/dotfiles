# [lazygit.nix](https://github.com/nix-community/home-manager/blob/master/modules/programs/lazygit.nix)
{
  # [lazygit.options](https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md)
  den.default.homeManager.programs.lazygit = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };
}
