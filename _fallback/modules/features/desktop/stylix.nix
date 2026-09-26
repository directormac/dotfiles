{ self, ... }: {

  flake.homeModules.stylix = {

    stylix = {
      targets = {

        gtk = {
          enable = true;
        };

        qt = {
          enable = true;
        };

        zen-browser = {
          enable = false;
          profileNames = [ ];
        };

        feh.enable = true;

        btop = {
          enable = true;

        };

        mangohud = {
          enable = true;
        };

        x11.enable = true;
      };

    };

  };

  flake.nixosModules.stylix = { pkgs, config, ... }: {

    home-manager.users.${config.preferences.user.name} = {
      imports = with self.homeModules; [
        stylix
      ];
    };

    stylix = {
      enable = true;
      polarity = "dark";

      autoEnable = false;

      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

      # fonts.fontconfig.defaultFonts = {
      #   serif = [ "Noto Serif" ];
      #   sansSerif = [ "Noto Sans" ];
      #   monospace = [ "Fira Mono Nerd Font" ];
      # };

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 16;
      };

      icons = {
        package = pkgs.adwaita-icon-theme;
        # name = "Adwaita";
      };

      fonts = {
        serif = {
          package = pkgs.noto-fonts;
          name = "Noto Serif";
        };

        sansSerif = {
          package = pkgs.noto-fonts;
          name = "Noto Sans";
        };

        monospace = {
          package = pkgs.nerd-fonts.fira-mono;
          name = "Fira Mono Nerd Font";
        };

        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };

      targets = {
        console.colors.enable = true;
      };
    };
  };
}
