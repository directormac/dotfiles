{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.lazygit =
    {
      pkgs,
      lib,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        self.packages.${pkgs.stdenv.hostPlatform.system}.lazygit
      ];
    };

  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      packages.lazygit = inputs.wrappers.lib.wrapPackage (
        {
          config,
          wlib,
          lib,
          ...
        }:
        {
          inherit pkgs;
          package = pkgs.lazygit;
          flags = {
            "--use-config-file" = ./lazygit.yml;
          };
        }
      );
    };
}
