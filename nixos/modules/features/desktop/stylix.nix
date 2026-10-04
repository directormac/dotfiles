{ inputs, self, ... }: {

  flake.homeModules.stylix =
    { config, lib, ... }:
    let
      inherit (config.lib.stylix) colors;
      mkColorTriple =
        name:
        lib.concatStringsSep "," [
          colors."${name}-rgb-r"
          colors."${name}-rgb-g"
          colors."${name}-rgb-b"
        ];
      colors' = builtins.listToAttrs (
        map (num: {
          name = "base0${lib.toHexString num}";
          value = mkColorTriple "base0${lib.toHexString num}";
        }) (lib.range 0 15)
      );
      kdecolors = with colors'; ''
        BackgroundNormal=${base00}
        BackgroundAlternate=${base01}
        DecorationFocus=${base0D}
        DecorationHover=${base0D}
        ForegroundNormal=${base05}
        ForegroundActive=${base05}
        ForegroundInactive=${base05}
        ForegroundLink=${base05}
        ForegroundVisited=${base05}
        ForegroundNegative=${base08}
        ForegroundNeutral=${base0D}
        ForegroundPositive=${base0B}
      '';

      kdeglobalsContent = ''
        [General]
        ColorScheme=Stylix
        Name=Stylix
        desktopFont=${config.stylix.fonts.sansSerif.name},${toString config.stylix.fonts.sizes.desktop},-1,5,50,0,0,0,0,0
        fixed=${config.stylix.fonts.monospace.name},${toString config.stylix.fonts.sizes.terminal},-1,5,50,0,0,0,0,0
        font=${config.stylix.fonts.sansSerif.name},${toString config.stylix.fonts.sizes.applications},-1,5,50,0,0,0,0,0
        menuFont=${config.stylix.fonts.sansSerif.name},${toString config.stylix.fonts.sizes.desktop},-1,5,50,0,0,0,0,0
        smallestReadableFont=${config.stylix.fonts.sansSerif.name},${toString config.stylix.fonts.sizes.desktop},-1,5,50,0,0,0,0,0
        taskbarFont=${config.stylix.fonts.sansSerif.name},${toString config.stylix.fonts.sizes.desktop},-1,5,50,0,0,0,0,0
        toolBarFont=${config.stylix.fonts.sansSerif.name},${toString config.stylix.fonts.sizes.desktop},-1,5,50,0,0,0,0,0

        [KDE]
        LookAndFeelPackage=stylix

        [UiSettings]
        ColorScheme=Stylix

        [Colors:Window]
        ${kdecolors}

        [Colors:View]
        ${kdecolors}

        [Colors:Button]
        ${kdecolors}

        [Colors:Tooltip]
        ${kdecolors}

        [Colors:Complementary]
        ${kdecolors}

        [Colors:Selection]
        BackgroundNormal=${colors'.base0D}
        BackgroundAlternate=${colors'.base0D}
        DecorationFocus=${colors'.base0D}
        DecorationHover=${colors'.base0D}
        ForegroundNormal=${colors'.base00}
        ForegroundActive=${colors'.base00}
        ForegroundInactive=${colors'.base00}
        ForegroundLink=${colors'.base00}
        ForegroundVisited=${colors'.base00}
        ForegroundNegative=${colors'.base08}
        ForegroundNeutral=${colors'.base0D}
        ForegroundPositive=${colors'.base0B}

        [WM]
        activeBackground=${colors'.base00}
        activeForeground=${colors'.base05}
        activeBlend=${colors'.base0A}
        inactiveBackground=${colors'.base00}
        inactiveForeground=${colors'.base05}
        inactiveBlend=${colors'.base03}
      '';
    in
    {
      imports = [ inputs.catppuccin.homeModules.catppuccin ];

      catppuccin = {
        enable = false;
        flavor = "mocha";
        accent = "mauve";
      };

      stylix = {
        enable = true;
      };

      xdg.configFile."kdeglobals".text = kdeglobalsContent;
      xdg.dataFile."color-schemes/Stylix.colors".text = kdeglobalsContent;
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
