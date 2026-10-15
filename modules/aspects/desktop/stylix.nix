# Stylix System-wide Theming Leaf Aspect (Catppuccin Mocha) with KDE Color Scheme & Custom Papirus Icons
{
  core,
  den,
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs = {
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  den.aspects.desktop.stylix = {
    nixos =
      { pkgs, ... }:
      let
        zenDarkSvg = ../../../config/zen-dark.svg;
      in
      {
        imports = lib.optionals (inputs ? stylix) [
          inputs.stylix.nixosModules.stylix
        ];

        environment.pathsToLink = [
          "/share/color-schemes"
        ];

        stylix = lib.mkIf (inputs ? stylix) {
          enable = true;
          polarity = "dark";
          autoEnable = false;

          base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

          cursor = {
            package = pkgs.catppuccin-cursors.mochaMauve;
            name = "catppuccin-mocha-mauve-cursors";
            size = 24;
          };

          icons = {
            enable = true;
            dark = "Papirus-Dark";
            light = "Papirus-Light";
            package = (pkgs.papirus-icon-theme.override { color = "violet"; }).overrideAttrs (oldAttrs: {
              postInstall =
                (oldAttrs.postInstall or "")
                + ''
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

    homeManager =
      { config, lib, ... }:
      let
        kdeglobalsContent =
          if config ? lib && config.lib ? stylix && config.lib.stylix ? colors then
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
          enable = true;
          autoEnable = false;

          targets = {
            kde.enable = lib.mkDefault true;
            gtk.enable = lib.mkDefault true;
            qt.enable = lib.mkDefault true;
            x11.enable = lib.mkDefault true;
          };
        };

        xdg.configFile."kdeglobals".text = lib.mkIf (kdeglobalsContent != "") kdeglobalsContent;
        xdg.dataFile."color-schemes/Stylix.colors".text = lib.mkIf (kdeglobalsContent != "") kdeglobalsContent;
      };
  };

}
