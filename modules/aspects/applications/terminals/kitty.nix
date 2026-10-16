# Kitty Terminal Emulator Leaf Aspect
_:
{
  den.aspects.applications.terminals.kitty = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.kitty
        ];
      };

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
        home.file.".config/kitty" = {
          recursive = true;
          source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/kitty";
        };

        home.packages = [
          pkgs.kitty
        ];
      };
  };
}
