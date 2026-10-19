# Niri Scrollable-Tiling Wayland Compositor Leaf Aspect
{
  lib,
  ...
}:
{
  den.aspects.desktop.niri = {
    nixos = {
      programs.niri.enable = lib.mkDefault true;
    };

    homeManager =
      {
        config,
        ...
      }:
      {
        home.file.".config/niri".source = config.lib.dots.link "niri";
      };

    persistHome.directories = [
      ".local/state/niri"
    ];
  };

}
