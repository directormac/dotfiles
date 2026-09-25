{
  flake.nixosModules.stylix = { pkgs, ... }: {
    stylix = {
      enable = true;
      polarity = "dark";

      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

      targets = {
        zen-browser = {
          enable = false;
          profileNames = [ ];
        };
      };

      # colors = {
      #   #scheme: "Catppuccin Mocha"
      #   # author: "https://github.com/catppuccin/catppuccin"
      #   base00 = "#1e1e2e"; # base
      #   base01 = "#181825"; # mantle
      #   base02 = "#313244"; # surface0
      #   base03 = "#45475a"; # surface1
      #   base04 = "#585b70"; # surface2
      #   base05 = "#cdd6f4"; # text
      #   base06 = "#f5e0dc"; # fg
      #   base07 = "#b4befe"; # light fg
      #   base08 = "#f38ba8"; # red
      #   base09 = "#fab387"; # orange
      #   base0A = "#f9e2af"; # yellow
      #   base0B = "#a6e3a1"; # green
      #   base0C = "#94e2d5"; # cyan
      #   base0D = "#89b4fa"; # blue
      #   base0E = "#cba6f7"; # magenta
      #   base0F = "#f2cdcd"; # orange
      # };

    };
  };
}
