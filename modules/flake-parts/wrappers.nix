# Nix-wrapper-modules flake-parts integration
{ inputs, ... }:
{
  flake-file.inputs = {
    wrappers = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nix-wrapper-modules";
    };
  };

  imports = [
    (inputs.wrappers.flakeModules.wrappers or { })
  ];
}
