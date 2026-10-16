# Desktop GTK, DConf & Bookmarks Leaf Aspect
_:
{
  den.aspects.desktop.gtk = {
    nixos =
      {
        lib,
        pkgs,
        ...
      }:
      let
        gtksettings = ''
          [Settings]
          gtk-icon-theme-name = ${icon-theme-name}
          gtk-theme-name = ${theme-name}
          gtk-application-prefer-dark-theme = 1
        '';
        icon-theme-name = "Papirus-Dark";
        icon-theme-package = pkgs.papirus-icon-theme;
        theme-name = "catppuccin-mocha-mauve-standard+default";
        theme-package = pkgs.catppuccin-gtk.override {
          accents = [ "mauve" ];
          size = "standard";
          variant = "mocha";
        };
      in
      {
        environment = {
          etc = {
            "xdg/gtk-3.0/settings.ini".text = gtksettings;
            "xdg/gtk-4.0/settings.ini".text = gtksettings;
          };

          systemPackages = [
            theme-package
            icon-theme-package
            pkgs.gtk3
            pkgs.gtk4
          ];
        };

        programs.dconf = {
          enable = lib.mkDefault true;

          profiles.user.databases = [
            {
              settings = {
                "org/gnome/desktop/interface" = {
                  color-scheme = "prefer-dark";
                  gtk-theme = theme-name;
                  icon-theme = icon-theme-name;
                };
              };

              lockAll = false;
            }
          ];
        };
      };

    homeManager =
      { config, ... }:
      {
        dconf.settings = {
          "org/gnome/desktop/privacy" = {
            remember-recent-files = false;
          };
        };

        gtk = {
          enable = true;

          gtk3.bookmarks = [
            "file://${config.home.homeDirectory}/Code Code"
            "file://${config.home.homeDirectory}/Projects Projects"
            "file://${config.home.homeDirectory}/Downloads Downloads"
            "file:///mnt/local/resources Resources(SSD)"
            "file:///mnt/network/fileserver Fileserver"
          ];
        };
      };
  };
}
