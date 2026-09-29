{
  inputs,
  self,
  config,
  ...
}:
{
  imports = [
    inputs.home-manager.flakeModules.home-manager

    inputs.wrappers.flakeModules.wrappers
  ];

  systems = [
    "x86_64-linux"
  ];

  # This is your system configuration entry-point
  flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      hardware
      nixosModule

      # Defined in nixos
      base

      # Features
      general
      desktop
      virtualisation

      inputs.nur.modules.nixos.default
      inputs.stylix.nixosModules.stylix
      inputs.nix-index-database.nixosModules.default
    ];
  };

  # This is your standalone home-manager configuration, meant to be used on non-nixos machines
  # with the home-manager command
  flake.homeConfigurations.home = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
    modules = with self.homeModules; [
      homeModule
      git
      {
        home.username = config.preferences.user.name;
        home.homeDirectory = "/home/${config.preferences.user.name}";
      }
    ];
  };

  perSystem = { pkgs, ... }: {

    devShells.default = pkgs.mkShell {
      packages = with pkgs; [

      ];
    };

  };

}
