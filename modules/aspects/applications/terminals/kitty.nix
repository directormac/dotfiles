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
      {
        home.file.".config/kitty" = {
          recursive = true;
          source = config.lib.dots.link "kitty";
        };

        home.packages = [
          pkgs.kitty
        ];
      };
  };
}
