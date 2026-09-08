{
  inputs,
  lib,
  self,
  ...
}:
{
  perSystem =
    {
      pkgs,
      self',
      ...
    }:
    {
      packages.terminal = inputs.lwrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.ghostty;
        flags = {
          "-e" = lib.getExe self'.packages.environment;
        };
      };
    };
}
