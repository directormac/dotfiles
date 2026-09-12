{ lib, ... }:
let
  theme = {
    #scheme: "Catppuccin Mocha"
    # author: "https://github.com/catppuccin/catppuccin"
    base00 = "#1e1e2e"; # base
    base01 = "#181825"; # mantle
    base02 = "#313244"; # surface0
    base03 = "#45475a"; # surface1
    base04 = "#585b70"; # surface2
    base05 = "#cdd6f4"; # text
    base06 = "#f5e0dc"; # fg
    base07 = "#b4befe"; # light fg
    base08 = "#f38ba8"; # red
    base09 = "#fab387"; # orange
    base0A = "#f9e2af"; # yellow
    base0B = "#a6e3a1"; # green
    base0C = "#94e2d5"; # cyan
    base0D = "#89b4fa"; # blue
    base0E = "#cba6f7"; # magenta
    base0F = "#f2cdcd"; # orange
  };

  stripHash =
    str:
    if builtins.substring 0 1 str == "#" then
      builtins.substring 1 (builtins.stringLength str - 1) str
    else
      str;

  themeNoHash = builtins.mapAttrs (_: v: stripHash v) theme;

  darken =
    percent: hex:
    let
      channel =
        offset:
        let
          value = lib.fromHexString (builtins.substring offset 2 (stripHash hex));
        in
        lib.toLower (lib.fixedWidthString 2 "0" (lib.toHexString (value * (100 - percent) / 100)));
    in
    "#${channel 0}${channel 2}${channel 4}";
  cursor = {
    name = "Bibata-Gruvbox";
    size = 24;
  };
in
{
  flake = {
    inherit
      theme
      themeNoHash
      darken
      cursor
      ;
  };
}
