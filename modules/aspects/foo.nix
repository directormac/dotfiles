{
  inputs,
  den,
  ...
}: {
  imports = [inputs.den.flakeModule];
  # --- Flake-level aspects ---

  # Read flake-parts classes from foo aspect and its includes
  den.schema.flake-parts.includes = [den.aspects.foo];

  den.aspects.foo = {
    includes = [den.aspects.bar];

    treefmt.settings.on-unmatched = "warn";

    devshell.commands = [{package = "cowsay";}];

    packages = {pkgs, ...}: {
      inherit (pkgs) htop;
    };
  };
}
