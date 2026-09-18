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
  den.aspects.artifex = {config, ...}: {
    includes = let
      # hack for nixf linter to keep findFile :/
      # this hack enables the <aspect/subaspect> below
      unused = den.lib.take.unused __findFile;
      __findFile = unused den.lib.__findFile;
    in [
      den.provides.define-user
      den.provides.primary-user
      den.aspects.tools.provides.nix-trusted-user
      den.batteries.host-aspects

      den.aspects.setHost

      <editor/helix>

      <editor/lazyvim>

      # den.aspects.editor.helix
      # den included batteries that provide common configs.
      <den/primary-user> # artifex is admin always.

      (<den/user-shell> "zsh") # default user shell

      # explicit policy activation
      den.aspects.artifex.policies.to-sandbox

      # runner.autologin
    ];

    nixos = {pkgs, ...}: {
      users.users.artifex.packages = [pkgs.vim];
    };

    homeManager = {
      pkgs,
      config,
      ...
    }: {
      # wayland.windowManager.hyprland.systemd.enable = false;
      home.packages = [
        pkgs.btop
      ];

      home.file = {
        ".face" = {
          source = ../../../config/.face;
        };
      };
    };

    user = {
      createHome = true;

      description = config.meta.fullname;
      extraGroups = [
        "kvm"
        "libvirt"
        "libvirt-qemu"
        "networkmanager"
        "root"
        "wheel"
      ];

      initialPassword = "12345";
    };

    meta = {
      email = "mac@mkra.dev";
      # fullname = "Mark Kendrick Asena";
      fullname = "Mac Asena";
      usename = "artifex";
    };

    # <user>.policies.<name>, aspect-included policy
    # Delivers NixOS config to the host (cross-scope via policy.provide).
    policies.to-sandbox = {
      host,
      user,
      ...
    }:
      lib.optionals (host.name == "sandbox") [
        (den.lib.policy.provide {
          class = "nixos";
          module.programs.nh.enable = true;
        })
        (den.lib.policy.include den.aspects.desktop.niri)
        (den.lib.policy.include den.aspects.desktop.hyprland)
      ];
  };

  den.aspects.setHost = {host, ...}: {
    networking.hostName = host.hostName;
  };
}
