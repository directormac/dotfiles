# Desktop KDE Connect Leaf Aspect
{
  den.aspects.desktop.kdeconnect = {
    homeManager = {
      services.kdeconnect = {
        enable = true;
        indicator = true;
      };
    };

    persistHome.directories = [
      ".config/kdeconnect"
      ".config/valent"
    ];
  };
}
