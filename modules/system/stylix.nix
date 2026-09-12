/**
# Stylix

  Stylix: system-wide base16 theming. Applies the host's configured
  color scheme, polarity, and wallpaper to all Stylix-compatible
  applications (Firefox, Kitty, Helix, GTK, etc.).
  Fonts: Arimo Nerd Font for UI, JetBrainsMono Nerd Font for monospace.

  [stylix](https://nix-community.github.io/stylix/)
  [configuration](https://nix-community.github.io/stylix/configuration.html)
*/
{
  inputs,
  lib,
  ...
}: {
  flake-file.inputs = {
    stylix.url = "github:danth/stylix/release-26.05";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
  };

  /***/

  den.aspects.stylix = {
    nixos = {
      pkgs,
      host,
      ...
    }: {
      imports = [inputs.stylix.nixosModules.stylix];
      stylix = {
        enable = true;
        # Dynamically loaded from the host's theme definition
        base16Scheme = host.theme.scheme;
        inherit (host.theme) polarity;
        image = host.theme.wallpaper;

        cursor = {
          package = pkgs.catppuccin-cursors;
          name = "mochaDark";
          size = 24;
        };

        fonts = {
          serif = {
            package = pkgs.nerd-fonts.noto;
            name = "Noto Nerd Font";
          };

          sansSerif = {
            package = pkgs.nerd-fonts.fira-code;
            name = "FiraCode Nerd Font";
          };

          monospace = {
            package = pkgs.nerd-fonts.fira-mono;
            name = lib.mkDefault "FiraCode Nerd Font Mono";
          };

          emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };

          sizes.popups = 12;
          sizes.desktop = 12;
        };
      };
    };
  };
}
