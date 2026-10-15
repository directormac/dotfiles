# Hyprland Wayland Compositor Aspect
{
  core,
  inputs,
  lib,
  ...
}:
{
  core.hyprland = {
    nixos =
      { pkgs, lib, ... }:
      {
        programs.uwsm.enable = lib.mkDefault true;
        programs.hyprland = {
          enable = lib.mkDefault true;
          withUWSM = lib.mkDefault true;
          xwayland.enable = lib.mkDefault true;
        };

        environment.systemPackages = with pkgs; [
          wl-clipboard
          wlr-randr
          brightnessctl
          playerctl
          xdg-utils
        ];
      };

    homeManager =
      {
        config,
        pkgs,
        user,
        ...
      }:
      let
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
      in
      {
        home.packages = with pkgs; [
          hyprlauncher
          hyprland-qt-support
          hyprland-preview-share-picker
        ];

        xdg.configFile."hypr".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/hypr";
      };

    persistHome.directories = [
      ".local/share/hyprland"
    ];
  };

  # Attach to workstation aspect
  core.workstation.includes = [
    core.hyprland
  ];
}
