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
    inputs.agenix-rekey.flakeModule
    inputs.devshell.flakeModule
    inputs.treefmt-nix.flakeModule
    inputs.flake-root.flakeModule
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
    ];
  };

  # This is your standalone home-manager configuration, meant to be used on non-nixos machines
  # with the home-manager command
  flake.homeConfigurations.home = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
    modules = with self.homeModules; [
      preferences
      homeModule
      git
      (
        { config, ... }:
        {
          home.username = config.preferences.user.name;
          home.homeDirectory = "/home/${config.preferences.user.name}";
        }
      )
    ];
  };

}
