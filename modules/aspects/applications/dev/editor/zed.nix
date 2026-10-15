# Zed Editor Aspect
{ den, ... }:
{
  den.aspects.applications.dev.editor.zed = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.zed-editor
        ];
      };

    persistHome.directories = [
      ".config/zed"
      ".local/share/zed"
    ];
  };
}
