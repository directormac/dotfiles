# Kitty Terminal Emulator Leaf Aspect
{ den, ... }:
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
          source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/kitty";
          recursive = true;
        };

        home.packages = [
          pkgs.kitty
        ];
      };
  };
}
