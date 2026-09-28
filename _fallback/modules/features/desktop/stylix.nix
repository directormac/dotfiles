{ self, ... }: {

  flake.homeModules.stylix = {

    stylix = {
      targets = {
        dank-calendar.enable = true;

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
        foliate.enable = true;
        mpv.enable = true;

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

    # config.stylix = {
    #   testbed = {
    #     enable = true;
    #   };
    #
    #   home-manager.sharedModules = lib.singleton {
    #     # Write Home Manager options here
    #   };
    # };

    stylix = {
      enable = true;
      polarity = "dark";

      autoEnable = false;

      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

      # Forces Stylix's main accent (base0D) to use the Catppuccin Mauve hex code
      override = {
        base0D = "cba6f7"; # Standard Catppuccin Mocha Mauve hex
      };

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 16;
      };

      icons = {
        # package = pkgs.adwaita-icon-theme;
        package = pkgs.papirus-icon-theme;
        dark = "Papirus-Dark";
        light = "Papirus-Light";
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
        console.enable = true;
        chromium.enable = true;
      };
    };
  };
}
