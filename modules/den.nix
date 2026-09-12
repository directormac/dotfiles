{
  den,
  lib,
  inputs,
  ...
}: {
  den.hosts.x86_64-linux.igloo.users.alice = {};
  den.homes.x86_64-linux.alice = {};

  den.hosts.x86_64-linux.igloo.users.tux = {};

  # enable hm for all users
  den.schema.user.classes = lib.mkDefault ["homeManager"];

  # --- Pipeline wiring ---

  # Enter flake-parts scope from flake-system.
  den.schema.flake-system.includes = [den.policies.system-to-flake-parts];

  # Exclude vanilla packages route — handled via flake-parts scope.
  den.schema.flake-system.excludes = [den.policies.packages-to-flake];
}
