{ inputs, self, ... }: {

  flake.homeModules.stylix = {
    imports = [ inputs.catppuccin.homeModules.catppuccin ];

    catppuccin = {
      enable = false;
      enableReleaseCheck = false;
      flavor = "mocha";
      accent = "mauve";
    };

    stylix = {
      enable = true;
    };
  };

  flake.nixosModules.stylix = { pkgs, config, ... }: {
    imports = [
      inputs.stylix.nixosModules.stylix
      inputs.catppuccin.nixosModules.catppuccin
    ];

    home-manager.users.${config.preferences.user.name} = {
      imports = with self.homeModules; [
        stylix
      ];
    };

    # catppuccin = {
    #   enable = true;
    #   autoEnable = false;
    #   enableReleaseCheck = false;
    #   accent = "mauve";
    # };

    stylix = {
      enable = true;
      polarity = "dark";

      autoEnable = false;

      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

      cursor = {
        # The package provides pre-compiled variants like 'mochaMauve'
        package = pkgs.catppuccin-cursors.mochaMauve;

        # The internal Xcursor theme name matching this variant
        name = "catppuccin-mocha-mauve-cursors";
        size = 24;
      };

      icons = {
        enable = true;
        # package = pkgs.adwaita-icon-theme;
        # package = pkgs.papirus-icon-theme.override { color = "violet"; };
        dark = "Papirus-Dark";
        light = "Papirus-Light";

        package = (pkgs.papirus-icon-theme.override { color = "violet"; }).overrideAttrs (oldAttrs: {
          postInstall = (oldAttrs.postInstall or "") + ''
            # Define the path to your downloaded dark logo
            DARK_ZEN_SVG="${../../../../config/zen-dark.svg}"

            # Overwrite the standard zen icons in the relevant Papirus sizes
            for size in 16x16 22x22 24x24 32x32 48x48 64x64 128x128 scalable; do
              if [ -d "$out/share/icons/Papirus/$size/apps" ]; then
                cp -f "$DARK_ZEN_SVG" "$out/share/icons/Papirus/$size/apps/zen-browser.svg"
                cp -f "$DARK_ZEN_SVG" "$out/share/icons/Papirus/$size/apps/zen-icon.svg"
              fi
              if [ -d "$out/share/icons/Papirus-Dark/$size/apps" ]; then
                cp -f "$DARK_ZEN_SVG" "$out/share/icons/Papirus-Dark/$size/apps/zen-browser.svg"
                cp -f "$DARK_ZEN_SVG" "$out/share/icons/Papirus-Dark/$size/apps/zen-icon.svg"
              fi
            done
          '';
        });

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
        plymouth.enable = true;
        chromium.enable = true;
      };

    };
  };
}
