/**
* User: artifex
*
* This file declares the 'artifex' user and configures their environments.
*
* HOW TO ADD A NEW USER:
* 1. Duplicate this file (e.g. `cp artifex.nix newuser.nix`).
* 2. Change all occurrences of `artifex` to `newuser`.
* 3. Don't forget to attach this user to a host in the host's entity file!
*/
{
  den,
  lib,
  runner,
  ...
}: {
  # --- User Registration ---
  den.homes.x86_64-linux.artifex = {};

  # --- User Configuration Aspect ---
  den.aspects.artifex = {
    # Alice can include other aspects.
    # For small, private one-shot aspects, use let-bindings like here.
    # for more complex or re-usable ones, define on their own modules,
    # as part of any aspect-subtree.
    includes = let
      # hack for nixf linter to keep findFile :/
      unused = den.lib.take.unused __findFile;
      __findFile = unused den.lib.__findFile;

      customEmacs.homeManager = {pkgs, ...}: {
        programs.emacs.enable = true;
        programs.emacs.package = pkgs.emacs-nox;
      };
    in [
      # from local bindings.
      customEmacs

      den.aspects.setHost

      runner.autologin

      <editor/helix>

      # den.aspects.editor.helix
      # den included batteries that provide common configs.
      <den/primary-user> # artifex is admin always.

      (<den/user-shell> "zsh") # default user shell
      # explicit policy activation
      den.aspects.artifex.policies.to-igloo
    ];

    nixos = {pkgs, ...}: {
      users.users.artifex.packages = [pkgs.vim];
      users.users.artifex.description = "Artifex";
    };

    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.htop];
    };

    # <user>.policies.<name>, aspect-included policy
    # Delivers NixOS config to the host (cross-scope via policy.provide).
    policies.to-igloo = {
      host,
      user,
      ...
    }:
      lib.optional (host.name == "sandbox") (
        den.lib.policy.provide {
          class = "nixos";
          module.programs.nh.enable = true;
        }
      );
  };

  den.aspects.setHost = {host, ...}: {
    networking.hostName = host.hostName;
  };
}
