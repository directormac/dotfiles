{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.starship =
    {
      pkgs,
      lib,
      ...
    }:
    {
      programs.starship = {
        enable = true;
        enableZshIntegration = true; # Prevents writing to /run/current-system/sw/bin/starship in zsh
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.starship;
        settings = ./starship.toml;
        # settings = { };
      };
    };
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
        }
      );
    };
}
