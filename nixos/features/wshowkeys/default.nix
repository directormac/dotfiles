{ moduleWithSystem, ... }: {
  flake.nixosModules.wshowkeys = moduleWithSystem (
    {
      self',
      pkgs,
      ...
    }:
    let
      lib = pkgs.lib;
    in
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
