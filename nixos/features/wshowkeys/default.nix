{ moduleWithSystem, ... }: {
  flake.nixosModules.wshowkeys = moduleWithSystem (
    {
      self',
      ...
    }:
    {
      programs.wshowkeys = {
        enable = true;
        package = self'.packages.wshowkeys;
      };
    }
  );
  perSystem = { inputs', ... }: {
    packages.wshowkeys = inputs'.wshowkeys.packages.default;
  };
}
