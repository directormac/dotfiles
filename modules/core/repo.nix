/**
* Repository Environment & Tooling Config
*
* This file configures the global flake-level outputs for the repository,
* such as the formatting rules and the development shell (`nix develop`).
*
* (Previously split across the poorly-named `foo.nix` and `bar.nix`).
*/
{
  inputs,
  den,
  ...
}: {
  imports = [inputs.den.flakeModule];

  # Route this configuration directly into the global flake-parts output
  den.schema.flake-parts.includes = [den.aspects.repo-env];

  den.aspects.repo-env = {
    # --- Formatter Configuration ---
    treefmt.programs.alejandra.enable = true;
    treefmt.settings.global.excludes = ["flake.nix" "config/**"];
    treefmt.settings.on-unmatched = "info";

    # --- Devshell Configuration ---
    # These packages are available when you run `nix develop` or use direnv.
    devshell = {
      pkgs,
      self',
      ...
    }: {
      commands = [
        {package = "age";}
        {package = "just";}
        {package = "sops";}
        {package = self'.packages.write-files;}
      ];
      packages = [pkgs.hello];
    };

    # --- Global Packages & Helpers ---
    packages = {
      pkgs,
      config,
      ...
    }: {
      inherit (pkgs) htop;
      write-files = config.files.writer.drv;
    };

    # --- Global Tests ---
    tests.test-math-works = {
      expr = 22 * 2;
      expected = 44;
    };
  };
}
