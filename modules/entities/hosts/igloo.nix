/**
* Host: igloo
*
* This file declares the 'igloo' host and configures it.
*
* HOW TO ADD A NEW HOST:
* 1. Duplicate this file (e.g. `cp igloo.nix newhost.nix`).
* 2. Change all occurrences of `igloo` to `newhost`.
* 3. Assign any users that belong to this new host in the `den.hosts` block below.
*/
{
  den,
  lib,
  ...
}: {
  # --- Host & User Registration ---
  den.hosts.x86_64-linux.igloo.users.alice = {};
  den.hosts.x86_64-linux.igloo.users.tux = {};

  # --- Host Configuration Aspect ---
  den.aspects.igloo = {
    # igloo host provides some home-manager defaults to its users.
    homeManager.programs.direnv.enable = true;

    # NixOS configuration for igloo.
    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.hello];
    };

    # <host>.policies.<name>, aspect-included policy
    policies.to-alice = {
      host,
      user,
      ...
    }:
      lib.optional (user.name == "alice") (
        den.lib.policy.include {
          homeManager.programs.tmux.enable = user.name == "alice";
        }
      );

    includes = [
      den.aspects.igloo.policies.to-alice
    ];
  };
}
