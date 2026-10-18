# TorLink Aspect
{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    # torlink.url = "github:baairon/torlink";
    torlink.url = "github:WarlaxZ/torlink";
  };

  den.aspects.applications.productivity.torlink = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = lib.optionals (inputs ? torlink) [
          inputs.torlink.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
      };
  };
}
