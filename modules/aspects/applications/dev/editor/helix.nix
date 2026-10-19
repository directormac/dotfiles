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
      { config, ... }:
      {
        home.file.".config/helix".source = config.lib.dots.link "helix";
        programs.helix.enable = true;
      };
  };
}
