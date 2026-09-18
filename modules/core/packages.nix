/**
* Packages Wiring (pkgs-by-name)
*
* This module hooks into the `pkgs-by-name-for-flake-parts` module.
* It automatically exposes any packages you define in the top-level `packages/`
* directory as flake outputs (`packages.<system>.<name>`), mirroring the
* standard nixpkgs `pkgs/by-name` convention.
*
* Use Case: When you drop a folder with a `package.nix` in `packages/`,
* this module ensures it becomes buildable via `nix build .#<name>`.
*/
{
  inputs,
  den,
  ...
}: {
  imports = [inputs.pkgs-by-name-for-flake-parts.flakeModule];
  perSystem.pkgsDirectory = ../../packages;
  den.schema.flake-parts.includes = [den.policies.packages-to-flake-parts];
}
