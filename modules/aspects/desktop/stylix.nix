# Stylix System-wide Theming Leaf Aspect (Catppuccin Mocha) with KDE Color Scheme & Custom Papirus Icons
{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    catppuccin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:catppuccin/nix";
    };

    stylix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/stylix";
    };
  };

  den.aspects.desktop.stylix = {
    nixos =
      { pkgs, ... }:
      let
        zenDarkSvg = ../../../config/zen-dark.svg;
      in
      {
        environment.pathsToLink = [
          "/share/color-schemes"
        ];

        imports = lib.optionals (inputs ? stylix) [
          inputs.stylix.nixosModules.stylix
        ];

        stylix = lib.mkIf (inputs ? stylix) {
          autoEnable = false;
          base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

          cursor = {
            name = "catppuccin-mocha-mauve-cursors";
            package = pkgs.catppuccin-cursors.mochaMauve;
            size = 24;
          };

          enable = true;

          fonts = {
            emoji = {
              name = "Noto Color Emoji";
              package = pkgs.noto-fonts-color-emoji;
            };

            monospace = {
              name = "Fira Mono Nerd Font";
              package = pkgs.nerd-fonts.fira-mono;
            };

            sansSerif = {
              name = "Noto Sans";
              package = pkgs.noto-fonts;
            };

            serif = {
              name = "Noto Serif";
              package = pkgs.noto-fonts;
            };
          };

          icons = {
            dark = "Papirus-Dark";
            enable = true;
            light = "Papirus-Light";

            package = (pkgs.papirus-icon-theme.override { color = "violet"; }).overrideAttrs (oldAttrs: {
              postInstall = (oldAttrs.postInstall or "") + ''
                DARK_ZEN_SVG="${zenDarkSvg}"
                if [ -f "$DARK_ZEN_SVG" ]; then
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
                fi
              '';
            });
          };

          polarity = "dark";

          targets = {
            chromium.enable = true;
            console.enable = true;
            plymouth.enable = true;
          };
        };
      };

    homeManager =
      { config, lib, ... }:
      let
        kdeglobalsContent =
          if config ? lib && config.lib ? stylix && config.lib.stylix ? colors then
            let
              inherit (config.lib.stylix) colors;
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
              mkColorTriple =
                name:
                lib.concatStringsSep "," [
                  colors."${name}-rgb-r"
                  colors."${name}-rgb-g"
                  colors."${name}-rgb-b"
                ];
            in
            ''
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
            ''
          else
            "";
      in
      {
        stylix = lib.mkIf (inputs ? stylix) {
          autoEnable = false;
          enable = true;

          targets = {
            gtk.enable = lib.mkDefault true;
            kde.enable = lib.mkDefault true;
            qt.enable = lib.mkDefault true;
            x11.enable = lib.mkDefault true;
          };
        };

        xdg.configFile."kdeglobals".text = lib.mkIf (kdeglobalsContent != "") kdeglobalsContent;

        xdg.dataFile."color-schemes/Stylix.colors".text = lib.mkIf (
          kdeglobalsContent != ""
        ) kdeglobalsContent;
      };
  };

}
