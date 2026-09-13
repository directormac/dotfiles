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

    devshell.commands = [
      {package = "age";}
      {package = "just";}
      {package = "sops";}
    ];

    packages = {pkgs, ...}: {
      inherit (pkgs) htop;
    };
  };
}
