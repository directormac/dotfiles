{ lib, pkgs, ... }: {

  home.file.".config/helix/config.toml".source = ./config.toml;
  home.file.".config/helix/themes/artifex.toml".source = ./themes/artifex.toml;

  programs.helix = {
    enable = true;
    languages.language = [{
      name = "nix";
      auto-format = true;
      formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
    }];

    # settings = {
    #   theme = "autumn_night_transparent";
    #   editor.cursor-shape = {
    #     insert = "bar";
    #     normal = "block";
    #     select = "underline";
    #   };
    # };
    # themes = {
    #   autumn_night_transparent = {
    #     "inherits" = "autumn_night";
    #     "ui.background" = { };
    #   };
    # };
  };

}
