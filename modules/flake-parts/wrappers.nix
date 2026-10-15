# Nix-wrapper-modules flake-parts integration
{ inputs, ... }:
{
  flake-file.inputs = {
    wrappers = {
      url = "github:nix-community/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  imports = [
    (inputs.wrappers.flakeModules.wrappers or { })
  ];
}
