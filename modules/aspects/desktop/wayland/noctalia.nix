{inputs, ...}: {
  # flake-file.inputs = {
  #   noctalia.url = "github:noctalia-dev/noctalia";
  #   noctalia.inputs.nixpkgs.follows = "nixpkgs";
  # };

  den.aspects.desktop.noctalia = {
    nixos = {
      programs.noctalia.enable = true;
    };

    homeManager = {
      pkgs,
      config,
      ...
    }: {
      programs.noctalia = {
        enable = true;
      };
    };
  };
}
