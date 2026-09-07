{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.git =
    {
      pkgs,
      lib,
      ...
    }:
    {
      programs.starship = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.starship;
      };
    };
  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    let
      config-file = ./starship.toml;
    in
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
          settings = config-file;
        }
      );
    };
}
