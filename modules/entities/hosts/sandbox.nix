/**
* Host: sandbox
*
* This file declares the 'sandbox' host and configures it.
*
* HOW TO ADD A NEW HOST:
* 1. Duplicate this file (e.g. `cp sandbox.nix newhost.nix`).
* 2. Change all occurrences of `sandbox` to `newhost`.
* 3. Assign any users that belong to this new host in the `den.hosts` block below.
*/
{
  den,
  lib,
  ...
}: {
  # --- Host & User Registration ---
  den.hosts.x86_64-linux.sandbox.users.artifex = {};
  # den.hosts.x86_64-linux.sandbox.users.alice = {};
  # den.hosts.x86_64-linux.sandbox.users.tux = {};

  # --- Host Configuration Aspect ---
  den.aspects.sandbox = {
    # sandbox host provides some home-manager defaults to its users.
    homeManager.programs.direnv.enable = true;

    # NixOS configuration for sandbox.
    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.hello];

      # Enable SSH for easier debugging
      services.openssh = {
        enable = true;
        settings.PermitRootLogin = "yes";
      };

      # Use ly as the default display manager for the sandbox
      services.displayManager.ly.enable = true;

      virtualisation.vmVariant = {
        virtualisation.forwardPorts = [
          {
            from = "host";
            host.port = 2222;
            guest.port = 22;
          }
        ];
      };
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
      den.aspects.sandbox.policies.to-alice
    ];
  };
}
