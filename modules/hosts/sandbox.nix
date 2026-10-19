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

    description = "NixOS Sandbox Testbed";
  };

  den.hosts.x86_64-linux.sandbox = {
    description = "NixOS Sandbox Testbed";
    isWorkstation = false;
    users.artifex = { };
  };
}
