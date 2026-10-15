# ZenNotes Note-Taking Aspect
{
  den,
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs = {
    zennotes.url = "github:ZenNotes/zennotes";
  };

  den.aspects.applications.productivity.zennotes = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = lib.optionals (inputs ? zennotes) [
          inputs.zennotes.packages.${pkgs.stdenv.hostPlatform.system}.zennotes-desktop
        ];
      };
  };
}
