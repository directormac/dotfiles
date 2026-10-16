# User: artifex
{
  lib,
  den,
  ...
}:
{
  den.aspects.artifex = {
    includes =

      [
        # Projects user-relevant classes (like homeManager) from the host's aspect tree onto users who opt in
        den.batteries.host-aspects

        # Sets login shell to zsh at both OS and Home Manager levels
        (den.batteries.user-shell "zsh")

        # Marks user as primary (wheel, networkmanager)
        den.batteries.primary-user
      ];

    nixos =
      { config, ... }:
      let
        hasPwdSecret = builtins.pathExists (../.. + "/.secrets/users/artifex/password.age");
      in
      {
        users.users.artifex = {
          description = "artifex's account";

          extraGroups = [
            "kvm"
            "libvirtd"
            "render"
          ];

          linger = true;
        }
        // (
          if hasPwdSecret then
            {
              hashedPasswordFile = config.age.secrets."password-artifex".path;
            }
          else
            {
              initialPassword = "12345";
            }
        );
      };

    homeManager =
      { pkgs, ... }:
      {
        home.homeDirectory = "/home/artifex";
        home.packages = [ pkgs.htop ];
        home.username = "artifex";
      };

    provides.to-hosts.nixos = _: { };

    secrets =
      let
        pwdSecret = ../.. + "/.secrets/users/artifex/password.age";
      in
      lib.optionalAttrs (builtins.pathExists pwdSecret) {
        "password-artifex" = {
          mode = "0400";
          rekeyFile = pwdSecret;
        };
      };
  };
}
