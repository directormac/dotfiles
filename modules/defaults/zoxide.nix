# [zoxide.nix](https://github.com/nix-community/home-manager/blob/master/modules/programs/zoxide.nix)
# [zoxide.options](https://github.com/ajeetdsouza/zoxide#configuration)
{
  den.default.homeManager.programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    options = ["--cmd cd"];
  };
}
