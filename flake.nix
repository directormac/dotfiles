{

  description = "Mac's nix configuration";

  inputs = {
	nixpkgs.url = "nixpkgs/nixos-unstable";
	nixos.url = "nixpkgs/nixos-unstable";

	home_manager = {
	 url = "github:nix-community/home-manager/master";
	 inputs.nixpkgs.follows = "nixpkgs";
	};


	nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    	nixpkgs-wayland.inputs.nixpkgs.follows = "nixpkgs";

  	wezterm = {
	      url = "github:wez/wezterm/main?dir=nix";
	      inputs.nixpkgs.follows = "nixpkgs";
	};

  };

  outputs = inputs@{self, nixpkgs, home-manager, ...}:{
  nixosConfigurations.super= nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
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
