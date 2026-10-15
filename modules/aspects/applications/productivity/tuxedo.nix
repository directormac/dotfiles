# Tuxedo CLI Todo / Task Management Aspect
{ den, ... }:
{
  den.aspects.applications.productivity.tuxedo = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.tuxedo
        ];
      };

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
        home.file.".config/tuxedo".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/tuxedo";
      };
  };
}
