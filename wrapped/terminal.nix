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
      packages.terminal = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.ghostty;
        # flags = {
        #   "-e" = lib.getExe self'.packages.environment;
        # };
      };
    };
}
