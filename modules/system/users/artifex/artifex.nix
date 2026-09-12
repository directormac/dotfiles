/**
User aspect definition for Artifex. Composes den batteries to:
  1. Create the user account (define-user)
  2. Grant wheel + network group membership (primary-user)
  3. Set fish as the default shell at both OS and home-manager levels
  4. Forward host aspects to home-manager (host-aspects)
*/
{den, ...}: {
  den.aspects.artifex = {
    description = "Mark Asena";
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
      (den.batteries.user-shell "zsh")
      den.batteries.host-aspects
    ];
  };
}
