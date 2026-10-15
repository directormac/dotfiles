# Stylix System-wide Theming Aspect (Catppuccin Mocha)
{
  core,
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
  };

  core.stylix = {
    nixos =
      { pkgs, ... }:
      {
        imports = lib.optionals (inputs ? stylix) [
          inputs.stylix.nixosModules.stylix
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
            package = pkgs.papirus-icon-theme.override { color = "violet"; };
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
      { ... }:
      {
        stylix = lib.mkIf (inputs ? stylix) {
          enable = true;
          autoEnable = false;
        };
      };
  };

  # Attach to workstation aspect
  core.workstation.includes = [
    core.stylix
  ];
}
