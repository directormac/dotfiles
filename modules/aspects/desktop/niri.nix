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
        user,
        ...
      }:
      let
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
      in
      {
        home.file.".config/niri".source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/niri";
      };

    persistHome.directories = [
      ".local/state/niri"
    ];
  };

}
