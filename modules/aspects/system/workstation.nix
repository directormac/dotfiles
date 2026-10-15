# Workstation Aspect: aggregates desktop & interactive developer tools for workstations
{
  core,
  ...
}:
{
  core.workstation = {
    # Workstation tools provided to users on workstation hosts
    provides.to-users.includes = [
      core.editor
      core.herdr
    ];
  };

  den.aspects.nixos = {
    includes = [
      core.workstation
    ];

    description = "NixOS Workstation";
    isWorkstation = true;
  };

  den.aspects.sandbox = {
    description = "NixOS Sandbox Testbed";
    isWorkstation = false;
  };

  # Host capability flags and descriptions
  den.aspects.super = {
    includes = [
      core.workstation
    ];

    description = "Super Workstation";
    isWorkstation = true;
  };
}
