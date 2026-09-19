/**
* User: tux
*
* This file declares the 'tux' user and configures their environments.
*
* HOW TO ADD A NEW USER:
* 1. Duplicate this file (e.g. `cp tux.nix newuser.nix`).
* 2. Change all occurrences of `tux` to `newuser`.
* 3. Don't forget to attach this user to a host in the host's entity file!
*/
{
  den,
  runner,
  ...
}: {
  # --- User Registration ---
  den.homes.x86_64-linux.tux = {};

  # --- User Configuration Aspect ---
  den.aspects.tux = {
    includes = [
      den.batteries.define-user
      # runner.autologin
    ];
    user.description = "Bird";

    packages = {pkgs, ...}: {
      inherit (pkgs) cowsay;
    };

    tests = {tux, ...}: {
      test-tux-is-bird = {
        expr = tux.description;
        expected = "Bird";
      };
    };
  };
}
