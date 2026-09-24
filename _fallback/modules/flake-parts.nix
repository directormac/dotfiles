{ inputs, ... }: {
  imports = [
    # adds home-manager options to flake-parts
    inputs.home-manager.flakeModules.home-manager
  ];

  systems = [
    "x86_64-linux"
  ];
}
