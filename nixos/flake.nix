{
  description = "Flake'd nixos with hyprland.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    import-tree.url = "github:denful/import-tree";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    devshell.url = "github:numtide/devshell";
    direnv-instant.url = "github:Mic92/direnv-instant";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    systems.url = "github:nix-systems/default";
    flake-utils.url = "github:numtide/flake-utils";
    flake-root.url = "github:srid/flake-root";

    wrappers.url = "github:nix-community/nix-wrapper-modules";
    wrappers.inputs.nixpkgs.follows = "nixpkgs";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    blink-cmp = {
      url = "github:saghen/blink.cmp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    blink-lib = {
      url = "github:saghen/blink.lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lazyvim.url = "github:pfassina/lazyvim-nix";
    make-shell.url = "github:nicknovitski/make-shell";

    nix-vite-plus.url = "github:ryoppippi/nix-vite-plus";

    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    herdr.url = "github:herdrdev/herdr/v0.9.3";

    workmux.url = "github:raine/workmux";
    tmux-nerd-font-window-name.url = "github:joshmedeski/tmux-nerd-font-window-name";

    tmux-remux.url = "github:noamsto/tmux-remux";

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms-plugin-registry.url = "github:AvengeMedia/dms-plugin-registry";
    dankcalendar = {
      url = "github:AvengeMedia/dankcalendar";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-doom-emacs-unstraightened = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty.url = "github:ghostty-org/ghostty";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix-rekey.url = "github:oddlama/agenix-rekey";
    agenix-rekey.inputs.nixpkgs.follows = "nixpkgs";

    mise-nix.url = "github:wadackel/mise-nix";

    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    superfile.url = "github:yorukot/superfile";

    zennotes.url = "github:ZenNotes/zennotes";
    torlink.url = "github:baairon/torlink";

    # https://github.com/0xc000022070/zen-browser-flake#installation
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        # IMPORTANT: To ensure compatibility with the latest Firefox version, use nixpkgs-unstable.
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    llm-agents.url = "github:numtide/llm-agents.nix";

    nur.url = "github:nix-community/NUR";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nixcord = {
      url = "github:4evy/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

}
