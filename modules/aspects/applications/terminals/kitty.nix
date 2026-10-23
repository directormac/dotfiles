# Kitty Terminal Emulator Leaf Aspect
{
  den.aspects.applications.terminals.kitty = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.kitty
        ];
      };

    homeManager =
      {
        config,
        pkgs,
        ...
      }:
      let
        kitty-popup = pkgs.writeShellScriptBin "kitty-popup" ''
          exec ${pkgs.kitty}/bin/kitty --class=kitty-popup \
            --session "${config.home.homeDirectory}/.config/kitty/sessions/popup.session" \
            -o initial_window_width=130c \
            -o initial_window_height=36c \
            -o remember_window_size=no \
            "$@"
        '';
      in
      {
        home.file.".config/kitty" = {
          recursive = true;
          source = config.lib.dots.link "kitty";
        };
        home.packages = [
          pkgs.kitty
          kitty-popup
        ];
      };

  };
}
