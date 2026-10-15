# Host and User Entity Topology
{
  # Host "nixos" on x86_64-linux with user "artifex"
  den.hosts.x86_64-linux.nixos.users.artifex = { };
  # Dedicated sandbox host for rapid and isolated VM testing
  den.hosts.x86_64-linux.sandbox.users.artifex = { };
  # Primary host "super" on x86_64-linux with user "artifex"
  den.hosts.x86_64-linux.super.users.artifex = { };
}
