#   Flake parts.
#   [flake.parts](https://flake.parts/index.html)
#   [cheat-sheet](https://flake.parts/cheat-sheet.html)

{ inputs, ... }: {

  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];

  config = {
    systems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
# Flake parts template
# { self, inputs, ...}: {
#
# }
