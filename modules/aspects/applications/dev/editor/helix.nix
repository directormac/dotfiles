# Helix Editor Aspect
_:
{
  den.aspects.applications.dev.editor.helix = {
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
        home.file.".config/helix".source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/helix";
        programs.helix.enable = true;
      };

    persistHome.directories = [
      ".local/share/helix"
    ];
  };
}
