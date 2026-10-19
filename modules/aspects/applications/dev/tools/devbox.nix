# Devbox
{
  inputs,
  ...
}:
{
  flake-file = {
    inputs = {
      devbox.url = "github:jetify-com/devbox";
    };

  };

  den.aspects.applications.dev.tools.devbox = {

    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          inputs.devbox.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];

      };

    homeManager =
      {
        pkgs,

        ...
      }:
      {

        home.packages = [
          inputs.devbox.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];

      };

  };
}
