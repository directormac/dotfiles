{
  description = "Flake'd nixos with hyprland.";
  
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {

    systems = [
      "x86_64-linux"
      # "aarch64-linux"
      # "x86_64-darwin"
      # "aarch64-darwin"
    ];

    # The target here is 
    # `nixosConfigurations.HOSTNAME` which the configuration applies to in
    # hostname of configuration.nix
    flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
      ];
    };

    perSystem = { pkgs, ... }: {

      packages.default = pkgs.vim;

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          git
          vim
        ];
      };

    };
  };

}
