{

  description = "Mac's nix configuration";

  inputs = {
	nixpkgs.url = "nixpkgs/nixos-24.11";

	home_manager = {
	 url = "github:nix-community/home-manager/release-24.11";
	 inputs.nixpkgs.follows = "nixpkgs";
	};
  };

  outputs = inputs@{self, nixpkgs, home-manager, ...}:{
  nixosConfigurations.super= nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
	./configuration.nix

	home-manager.nixosModules.home-manager
	{
	 home-manager.useGlobalPkgs = true;
	 home-manager.useUserPackages = true;

	 home-manager.users.artifex = import ./home.nix;
	}
    ];
  };
  };
}
