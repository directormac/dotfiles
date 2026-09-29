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
  ];

  systems = [
    "x86_64-linux"
  ];

  perSystem = { config, pkgs, ... }: {
    # Add `config.agenix-rekey.package` to your devshell to
    # easily access the `agenix` command wrapper.
    devShells.default = pkgs.mkShell {
      nativeBuildInputs = [ config.agenix-rekey.package ];

      packages = with pkgs; [
        rage
      ];
      shellHook = ''
        alias age="rage"
      '';

    };

    # You can define agenix-rekey.nixosConfigurations / agenix-rekey.darwinConfigurations if you want to change which
    # hosts are considered for rekeying.
    # Refer to the flake.parts section on agenix-rekey to see all available options.
    agenix-rekey.nixosConfigurations = inputs.self.nixosConfigurations; # (not technically needed, as it is already the default)
  };

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

      # inputs.agenix.nixosModules.default
      # inputs.agenix-rekey.nixosModules.default
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

}
