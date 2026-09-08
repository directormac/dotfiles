{
  flake.nixosModules.gtk = {
    pkgs,
    lib,
    ...
  }: let
    theme-name = "catppuccin-mocha-mauve-standard+default";
    theme-package = pkgs.catppuccin-gtk.override {
      accents = [ "mauve" ];
      size = "standard";
      variant = "mocha";
    };

    icon-theme-package = pkgs.papirus-icon-theme;
    icon-theme-name = "Papirus-Dark";

    gtksettings = ''
      [Settings]
      gtk-icon-theme-name = ${icon-theme-name}
      gtk-theme-name = ${theme-name}
      gtk-application-prefer-dark-theme = 1
    '';
  in {
    environment = {
      etc = {
        "xdg/gtk-3.0/settings.ini".text = gtksettings;
        "xdg/gtk-4.0/settings.ini".text = gtksettings;
      };
    };


    programs = {
      dconf = {
        enable = lib.mkDefault true;
        profiles = {
          user = {
            databases = [
              {
                lockAll = false;
                settings = {
                  "org/gnome/desktop/interface" = {
                    gtk-theme = theme-name;
                    icon-theme = icon-theme-name;
                    color-scheme = "prefer-dark";
                  };
                };
              }
            ];
          };
        };
      };
    };

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = "*";
    };

    environment.systemPackages = [
      theme-package
      icon-theme-package

      pkgs.gtk3
      pkgs.gtk4
    ];
  };
}
