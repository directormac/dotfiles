{
  inputs,
  self,
  ...
}:
{
  flake.homeModules.herdr = { pkgs, ... }: {
    programs.herdr = {

      enable = true;

      package = inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default;

      settings = { };

    };
  };
  flake.nixosModules.herdr =
    { pkgs, config, ... }:
    {

      home-manager.users.${config.preferences.user.name} = {
        imports = [
          self.homeModules.herdr
        ];
      };

    };

  perSystem =
    { pkgs, ... }:
    {

    };
}
