#   Flake parts.
#   [flake.parts](https://flake.parts/index.html)
#   [cheat-sheet](https://flake.parts/cheat-sheet.html)
{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.home-manager.flakeModules.home-manager
    inputs.wrappers.flakeModules.wrappers
  ];

  options.flake.wrappersModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = {};
    description = "Wrapper modules for wrapper-modules";
  };

  config = {
    perSystem = {system, ...}: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    };

    systems = [
      "x86_64-linux"
      "aarch64-linux"
      # "x86_64-darwin"
      # "aarch64-darwin"
    ];
  };
}
