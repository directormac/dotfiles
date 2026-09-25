{ inputs, ... }: {

  flake.nixosModules.mangowc = { ... }: {
    imports = [
      inputs.mangowm.nixosModules.mango
    ];
    programs.mango.enable = true;
  };
}
