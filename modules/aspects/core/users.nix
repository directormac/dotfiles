# Core Users & Home Manager Base Settings Aspect
{ den, ... }:
{
  den.aspects.core.users = {
    nixos =
      _:
      {
        home-manager.backupFileExtension = "backup";
      };

    homeManager =
      _:
      {
        home.sessionPath = [ "$HOME/.local/bin" ];
      };
  };
}
