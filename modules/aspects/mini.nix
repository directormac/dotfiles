{
  den,
  lib,
  ...
}: {
  den.aspects.mini = {
    homeManager.programs.direnv.enable = true;

    # NixOS configuration for igloo.
    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.hello];
    };

    # <host>.policies.<name>, aspect-included policy
    policies.to-artifex = {
      host,
      user,
      ...
    }:
      lib.optional (user.name == "artifex") (
        den.lib.policy.include {
          homeManager.programs.tmux.enable = user.name == "artifex";
        }
      );

    includes = [den.aspects.mini.policies.to-artifex];
  };
}
