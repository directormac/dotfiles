# Television Fuzzy Finder Aspect
{ core, lib, ... }:
{
  core.television = {
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
        home.packages = with pkgs; [
          television
        ];

        xdg.configFile."television".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/television";
      };

    persistHome.directories = [
      ".local/share/television"
    ];
  };

  den.aspects.artifex.includes = [
    core.television
  ];
}
