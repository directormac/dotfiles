# Host "sandbox": Lightweight isolated testbed host for rapid VM testing
{
  den,
  ...
}:
{
  den.aspects.sandbox = {
    includes = with den.aspects; [
      roles.default
      applications.gaming.nix-ld
      virtualization.vm-variant.gui
      (den.batteries.vm-autologin "artifex")
    ];

    nixos =
      { lib, ... }:
      {
        # virtualization.vm-bootable imports the installer CD profile, which sets
        # root initialHashedPassword = "" (installation-device.nix). That collides
        # with the artifex aspect's initialPassword fallback and triggers NixOS'
        # multiple-password-options warning; the testbed has no use for the
        # installer's empty root hash.
        users.users.root.initialHashedPassword = lib.mkForce null;
      };

    description = "NixOS Sandbox Testbed";
  };

  den.hosts.x86_64-linux.sandbox = {
    description = "NixOS Sandbox Testbed";
    isWorkstation = false;
    users.artifex = { };
  };
}
