{ self, inputs, ... }: {
  flake.nixosConfigurations.vmachine = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.vmachineConfiguration
    ];
  };
}
