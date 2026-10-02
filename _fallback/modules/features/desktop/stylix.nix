{ inputs, self, ... }: {

  flake.homeModules.stylix = {
    stylix = {
      enable = true;
    };
  };

  flake.nixosModules.stylix = { pkgs, config, ... }: {
    imports = [
      inputs.stylix.nixosModules.stylix
    ];

    home-manager.users.${config.preferences.user.name} = {
      imports = with self.homeModules; [
        stylix
      ];
    };

    stylix = {
      enable = true;
      polarity = "dark";

      autoEnable = false;

      # Explicit Catppuccin Mocha Base16 Palette with Mauve as the primary accent
      base16Scheme = {
        base00 = "1e1e2e"; # Base
        base01 = "313244"; # Surface0 / Mantle
        base02 = "45475a"; # Surface1
        base03 = "6c7086"; # Overlay0
        base04 = "a6adc8"; # Subtext0
        base05 = "cdd6f4"; # Text
        base06 = "f5e0dc"; # Rosewater
        base07 = "b4befe"; # Lavender
        base08 = "f38ba8"; # Red
        base09 = "fab387"; # Peach
        base0A = "f9e2af"; # Yellow
        base0B = "a6e3a1"; # Green
        base0C = "94e2d5"; # Teal
        base0D = "cba6f7"; # Mauve (Main Accent)
        base0E = "cba6f7"; # Mauve
        base0F = "f2cdcd"; # Flamingo
      };

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
