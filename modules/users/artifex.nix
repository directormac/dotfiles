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

    # Configure root's password on hosts where artifex lives:
    # uses `root-password.age` if present, else shares `password.age`, else falls back to "12345".
    provides.to-hosts.nixos =
      { config, ... }:
      let
        hasRootPwdSecret = (config ? age) && (config.age.secrets ? "password-root");
        hasUserPwdSecret = (config ? age) && (config.age.secrets ? "password-artifex");
      in
      {
        users.users.root =
          if hasRootPwdSecret then
            {
              hashedPasswordFile = config.age.secrets."password-root".path;
              initialHashedPassword = null;
            }
          else if hasUserPwdSecret then
            {
              hashedPasswordFile = config.age.secrets."password-artifex".path;
              initialHashedPassword = null;
            }
          else
            {
              initialHashedPassword = null;
              initialPassword = "12345";
            };
      };

    secrets =
      { user, ... }:
      let
        pwdSecret = user.secretPath + "/password.age";
        rootPwdSecret = user.secretPath + "/root-password.age";
      in
      lib.optionalAttrs (builtins.pathExists pwdSecret) {
        "password-artifex" = {
          mode = "0400";
          rekeyFile = pwdSecret;
        };
      }
      // lib.optionalAttrs (builtins.pathExists rootPwdSecret) {
        "password-root" = {
          mode = "0400";
          rekeyFile = rootPwdSecret;
        };
      };

    # Configure the user's own OS account via the `user` class (`users.users.artifex`)
    # rather than untargeted `nixos` (see explanation/where-config-lands.mdx #694).
    user =
      {
        osConfig,
        ...
      }:
      let
        hasPwdSecret = (osConfig ? age) && (osConfig.age.secrets ? "password-artifex");
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
