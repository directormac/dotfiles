{
  self,
  inputs,
  ...
}:
{
  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      packages.starship = inputs.wrapper-modules.lib.wrapPackage (
        {
          config,
          wlib,
          lib,
          ...
        }:
        {
          inherit pkgs;
          package = pkgs.starship;
          env = {
            STARSHIP_CONFIG = toString ./starship.toml;
          };
        }
      );
    };
}
