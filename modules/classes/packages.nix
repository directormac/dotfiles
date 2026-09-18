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
  imports = [
    inputs.pkgs-by-name-for-flake-parts.flakeModule
  ];

  # perSystem = {system, ...}: {
  #   _module.args.pkgs = import inputs.nixpkgs {
  #     inherit system;
  #     overlays = [
  #       inputs.self.overlays.default
  #     ];
  #   };
  #   pkgsDirectory = ../../packages;
  # };

  perSystem.pkgsDirectory = ../../packages;

  # flake = {
  #   overlays.default = _final: prev:
  #     withSystem prev.stdenv.hostPlatform.system (
  #       {config, ...}: {
  #         local = config.packages;
  #       }
  #     );
  # };

  den.schema.flake-parts.includes = [
    den.policies.packages-to-flake-parts
  ];
}
