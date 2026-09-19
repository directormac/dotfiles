{inputs, ...}: {
  den.aspects.base.system.disko = {
    nixos = {
      imports = [inputs.disko.nixosModules.disko];
    };
  };
}
