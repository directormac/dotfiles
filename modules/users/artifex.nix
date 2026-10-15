# User: artifex
{
  den,
  lib,
  ...
}:
{
  den.aspects.artifex = {
    includes =
      let
        inherit (den.lib) __findFile;
      in
      with den.aspects;
      [
        # Projects user-relevant classes (like homeManager) from the host's aspect tree onto users who opt in
        den.batteries.host-aspects

        # Sets login shell to zsh at both OS and Home Manager levels
        (den.batteries.user-shell "zsh")

        # Marks user as primary (wheel, networkmanager)
        den.batteries.primary-user
      ];

    nixos =
      { ... }:
      {
        users.users.artifex = {
          linger = true;
          description = "artifex's account";
          extraGroups = [
            "kvm"
            "libvirtd"
            "render"
          ];
          initialPassword = "12345";
        };
      };

    homeManager =
      { pkgs, ... }:
      {
        home.homeDirectory = "/home/artifex";
        home.username = "artifex";
        home.packages = [ pkgs.htop ];
      };

    provides.to-hosts.nixos = _: { };
  };
}
