{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.lazygit =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.lazygit
      ];
    };

  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.lazygit = inputs.wrappers.lib.wrapPackage ({
        inherit pkgs;
        package = pkgs.lazygit;

        flags = {
          "--use-config-file" = ../../../config/lazygit/config.yml;
        };
      });

    };
}
