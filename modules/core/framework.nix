/**
* Den Engine & Pipeline Architecture
*
* NOTE: This file is absolutely necessary for the flake to function!
* It defines the internal data pipelines that translate your configurations
* into standard Nix outputs.
*
* Pipeline Phases:
* 1. `flake-system` policies: Ensure that hosts build without conflicting with standard packages.
* 2. `flake-parts` routing: Reads `perSystem` outputs (like packages, checks, devShells)
*    declared inside your hosts and translates them seamlessly into the flake.
*/
{
  den,
  lib,
  ...
}: let
  inherit (den.lib.policy) resolve;
in {
  # (Host and User declarations are now self-contained in modules/entities/)
  den.schema.user.classes = lib.mkDefault ["homeManager"];

  # --- Pipeline wiring ---
  # Enter flake-parts scope from flake-system.
  den.schema.flake-system.includes = [den.policies.system-to-flake-parts];

  # Exclude vanilla packages route — handled via flake-parts scope.
  den.schema.flake-system.excludes = [den.policies.packages-to-flake];

  # --- Flake-Parts Routing ---
  # Read flake-parts classes from hosts and their includes
  den.policies.flake-parts-to-host = _:
    map (host: resolve.to "host" {inherit host;}) (
      builtins.concatMap builtins.attrValues (builtins.attrValues den.hosts)
    );
  den.schema.flake-parts.includes = [den.policies.flake-parts-to-host];
}
