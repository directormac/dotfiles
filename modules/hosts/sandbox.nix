# Host "sandbox": Lightweight isolated testbed host for rapid VM testing
{
  core,
  den,
  lib,
  ...
}:
{
  den.hosts.x86_64-linux.sandbox = {
    description = "NixOS Sandbox Testbed";
    isWorkstation = false;
    users.artifex = { };
  };

  den.aspects.sandbox = {
    description = "NixOS Sandbox Testbed";
    isWorkstation = false;

    includes = with den.aspects; [
      roles.default
      applications.gaming.nix-ld
      virtualization.vm-variant.gui
      (den.batteries.vm-autologin "artifex")
    ];

    nixos = {
      networking.hostName = "sandbox";
      system.stateVersion = "26.05";
    };
  };
}
