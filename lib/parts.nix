#   Flake parts.
#   [flake.parts](https://flake.parts/index.html)
#   [cheat-sheet](https://flake.parts/cheat-sheet.html)

{ inputs, lib, ... }: {

  imports = [
    inputs.home-manager.flakeModules.home-manager
    inputs.wrappers.flakeModules.wrappers
  ];

  options.flake.lib = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
    description = "Helpers shared between modules in this flake";
  };

  config = {
    perSystem = { pkgs, ... }: {
      wrappers.control_type = "exclude"; # | "build" (default: "exclude")
      wrappers.packages = {
        # Set to true to exclude these from the `packages.*.*` flake output
        dynamic = true;
        which-key = true;
      };
    };

    systems = [
      "x86_64-linux"
      # "x86_64-darwin"
      "aarch64-linux"
      # "aarch64-darwin"
    ];
  };
}
# Flake parts template
# { self, inputs, ...}: {
#
# }
