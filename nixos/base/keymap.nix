{
  flake.nixosModules.base =
    {
      lib,
      pkgs,
      ...
    }:
    {
      options.preferences = {
        keymap = lib.mkOption {
          type = lib.types.lazyAttrsOf (lib.types.either lib.types.attrs lib.types.package);
          default = { };
          example = {
            "SUPER + d" = {
              "f" = {
                exec = "firefox";
              };
            };
          };
        };
      };
    };
}
