{__findFile, ...}: {
  den.ful.theme.catppuccin = {
    # Depends on Stylix
    includes = [
      <stylix>
      ({host, ...}: {host.theme.scheme = ./scheme.yaml;})
    ];
    host.class.theme = {
      scheme = ./scheme.yaml;
      polarity = "dark";
      wallpaper = ./wallpaper.png;
    };
  };
}
