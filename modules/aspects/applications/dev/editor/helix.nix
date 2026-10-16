{ den, ... }:
{
  den.aspects.applications.dev.editor.helix = {
    includes = with den.aspects.applications.dev; [
      lang.nix
      lang.lua
      lang.shell
      lang.markdown
      lang.data
      lang.kdl
      lang.node
      lang.elixir
    ];

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
