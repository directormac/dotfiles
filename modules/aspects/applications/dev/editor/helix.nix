# Helix Editor Aspect
{ den, ... }:
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
        programs.helix.enable = true;

        home.file.".config/helix".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/helix";
      };

    persistHome.directories = [
      ".local/share/helix"
    ];
  };
}
