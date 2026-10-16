# VS Code & SQLite Browser Aspect
{
  den.aspects.applications.dev.editor.vscode = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          vscode
          sqlitebrowser
        ];
      };

    persistHome.directories = [
      ".config/Code"
    ];
  };
}
