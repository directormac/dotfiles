# Lutris Game Manager Aspect
{
  den.aspects.applications.gaming.lutris = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.lutris
        ];
      };

    persistHome.directories = [
      ".local/share/lutris"
      ".config/lutris"
    ];
  };
}
