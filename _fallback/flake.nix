{
  description = "Flake'd nixos with hyprland.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    import-tree.url = "github:denful/import-tree";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    wrappers.url = "github:nix-community/nix-wrapper-modules";
    wrappers.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    impermanence.url = "github:nix-community/impermanence";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    lazyvim.url = "github:pfassina/lazyvim-nix";
    make-shell.url = "github:nicknovitski/make-shell";

    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    workmux.url = "github:raine/workmux";

    dms.url = "github:AvengeMedia/DankMaterialShell";
    dgop.url = "github:AvengeMedia/dgop";
    dms-plugin-registry.url = "github:AvengeMedia/dms-plugin-registry";
    dankcalendar.url = "github:AvengeMedia/dankcalendar";
    danksearch.url = "github:AvengeMedia/danksearch";

    # https://github.com/0xc000022070/zen-browser-flake#installation
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        # IMPORTANT: To ensure compatibility with the latest Firefox version, use nixpkgs-unstable.
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

}
