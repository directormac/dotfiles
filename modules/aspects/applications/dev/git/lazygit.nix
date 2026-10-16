# Lazygit TUI Git Client Aspect
_:
{
  den.aspects.applications.dev.git.lazygit = {
    homeManager =
      {
        config,
        user,
        ...
      }:
      let
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
      in
      {
        programs.lazygit.enable = true;
        xdg.configFile."lazygit".source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/lazygit";
      };

    persistHome.directories = [
      ".local/state/lazygit"
    ];
  };
}
