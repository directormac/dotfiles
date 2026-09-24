{ inputs, ... }: {
  # Docs https://flake-file.denful.dev/reference/options/
  flake-file = {
    description = "Mac's NixOS flake-parts-den-dendritic-aspect-oriented configurations. . . ";

    inputs = {
      flake-file.url = "github:denful/flake-file";
      den.url = "github:denful/den";
      den-diagram.url = "github:denful/den-diagram";
      flake-aspects.url = "github:denful/flake-aspects";
      flake-parts.url = "github:hercules-ci/flake-parts";

      home-manager = {
        inputs.nixpkgs.follows = "nixpkgs";
        url = "github:nix-community/home-manager";
      };

      home-manager-stable = {
        inputs.nixpkgs.follows = "nixpkgs-stable";
        url = "github:nix-community/home-manager/release-26.05";
      };

      import-tree.url = "github:denful/import-tree";
      nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
      nixpkgs-stable.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.xz";

      # nixdoc.url = "github:nix-community/nixdoc";

      # disko.url = "github:nix-community/disko";
      # nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
      # nixos-hardware.url = "github:nixos/nixos-hardware";

      # fastest.url =  "github:denful/fastest";
      # nest.url = "github:denful/nest";
      # Hardware related
      # nix-index-database.url = "github:nix-community/nix-index-database";
      # nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
      # impermanence.url = "github:nix-community/impermanence";
    };

    nixConfig = {
      accept-flake-config = true;
      allow-import-from-derivation = true;
      auto-optimise-store = true;

      # Flake-specific substituters and trusted-public-keys, not affecting the system configuration.
      extra-substituters = [
        # Nix community cache server.
        "https://nix-community.cachix.org"
        # Flox cache server.
        "https://cache.flox.dev"
        # Numtide cache server.
        "https://numtide.cachix.org"
        "https://cache.numtide.com"
      ];

      extra-trusted-public-keys = [
        # Nix community cache server public key.
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        # Flox cache server public key.
        "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
        # Numtide cache server public key.
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE"
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];

      lazy-trees = true;
      show-trace = true;
      submodules = true;
      use-xdg-base-directories = true;
    };

    prune-lock.enable = true;
  };

  imports = [
    # More flakeModules options from flake-file
    # https://flake-file.denful.dev/guides/flake-modules/
  ];

  debug = true;
  #   # NOTE We use the default `systems` defined by `nixpkgs`, if
  # you need any additional systems, simply add them in the following manner
  #
  # `systems = (inputs.nixpkgs.lib.systems.flakeExposed) ++ [ "armv7l-linux" ];`
  systems = inputs.nixpkgs.lib.systems.flakeExposed;
}
