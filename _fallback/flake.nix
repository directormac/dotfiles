{
  description = "Flake'd nixos with hyprland.";
  
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };


  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
    };
  };
}
