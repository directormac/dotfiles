{ self, inputs, ... }: {
  flake.nixosConfigurations.vmachine = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.home-manager.nixosModules.default
      self.nixosModules.vmachineConfiguration
    ];
  };
}
