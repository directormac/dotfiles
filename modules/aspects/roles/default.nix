# Base Host Role: core system leaves, hardware foundations, base services, and shell environment
{ den, ... }:
{
  den.aspects.roles.default = {
    includes = with den.aspects; [
      # Core System Leaves
      core.boot
      core.documentation
      core.locale
      core.mounts
      core.networking
      core.nix
      core.nixpkgs
      core.nh
      core.security
      core.users

      # Hardware Foundations
      hardware.bluetooth
      hardware.graphics
      hardware.input
      hardware.power

      # System Services
      services.avahi
      services.openssh
      services.printing
      services.samba
      services.smartd
      services.tailscale

      # Core Shell & CLI Utilities
      applications.shell.zsh
      applications.shell.carapace
      applications.shell.cli-utils
    ];
  };

  # Compatibility alias
}
