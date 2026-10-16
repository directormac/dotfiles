# Zed Editor Aspect
_:
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
