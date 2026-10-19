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

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.htop ];
      };

    secrets =
      { user, ... }:
      let
        pwdSecret = user.secretPath + "/password.age";
      in
      lib.optionalAttrs (builtins.pathExists pwdSecret) {
        "password-artifex" = {
          mode = "0400";
          rekeyFile = pwdSecret;
        };
      };

    # Configure the user's own OS account via the `user` class (`users.users.artifex`)
    # rather than untargeted `nixos` (see explanation/where-config-lands.mdx #694).
    user =
      {
        osConfig,
        user,
        ...
      }:
      let
        hasPwdSecret = builtins.pathExists (user.secretPath + "/password.age");
      in
      {
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
            hashedPasswordFile = osConfig.age.secrets."password-artifex".path;
          }
        else
          {
            initialPassword = "12345";
          }
      );
  };
}
