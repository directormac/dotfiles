# Desktop KDE Connect Leaf Aspect
{ den, ... }:
{
  den.aspects.desktop.kdeconnect = {
    homeManager =
      _:
      {
        services.kdeconnect = {
          enable = true;
          indicator = true;
        };
      };
  };
}
