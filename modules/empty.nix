{
  self,
  moduleWithSystem,
  ...
}:
{
  flake.nixosModules.name = moduleWithSystem (
    {
      pkgs,
      self',
      inputs',
      ...
    }:
    let
      modules = with self.nixosModules; [ ];
    in
    {
      imports = modules;
      programs.name = {
        enable = true;
        package = self'.packages.hello;
      };
    }
  );
  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      packages.hello = pkgs.hello;
    };
}
