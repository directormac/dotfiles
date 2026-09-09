{
  inputs,
  ...
}:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages = {
        starship = inputs.wrappers.lib.wrapPackage (
          {
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
    };
}
