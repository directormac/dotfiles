# Core Users & Home Manager Base Settings Aspect
{
  den.aspects.core.users = {
    nixos = {
      home-manager.backupFileExtension = "backup";
    };

    homeManager = {
      home.sessionPath = [ "$HOME/.local/bin" ];
    };
  };
}
