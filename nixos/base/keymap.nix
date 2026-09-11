{
  flake.nixosModules.base = {lib, ...}: {
    options.preferences = {
      keymap = lib.mkOption {
        type = lib.types.lazyAttrsOf (lib.types.either lib.types.attrs lib.types.package);
        default = {};
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
