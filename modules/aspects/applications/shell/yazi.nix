# Yazi Terminal File Manager Leaf Aspect
{
  core,
  den,
  ...
}:
{
  den.aspects.applications.shell.yazi = {
    homeManager =
      {
        config,
        pkgs,
        user,
        ...
      }:
      let
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
      in
      {
        programs.yazi = {
          enable = true;
          enableZshIntegration = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
        };

        home.packages = with pkgs; [
          file
          jq
          fd
          ripgrep
          fzf
          zoxide
          ffmpegthumbnailer
          unar
          p7zip
          imagemagick
        ];

        xdg.configFile."yazi".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/yazi";
      };

    persistHome.directories = [
      ".local/state/yazi"
    ];
  };

}
