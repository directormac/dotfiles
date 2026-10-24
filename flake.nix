# DO-NOT-EDIT. This file was auto-generated using github:denful/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  description = "Mac's NixOS flake-parts-den-dendritic-aspect-oriented configurations. . . ";

  inputs = {
    flake-file.url = "github:denful/flake-file";

    agenix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:ryantm/agenix";
    };

    agenix-rekey = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:oddlama/agenix-rekey";
    };

    blink-cmp = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:saghen/blink.cmp";
    };

    blink-lib = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:saghen/blink.lib";
    };

    catppuccin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:catppuccin/nix";
    };

    dag.url = "github:denful/dag";

    dankcalendar = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:duxlabs-dev/dux-calendar";
    };

    danksearch = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:duxlabs-dev/dux-search";
    };

    den.url = "github:denful/den";

    den-diagram = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:denful/den-diagram";
    };

    devbox.url = "github:jetify-com/devbox";
    devenv.url = "github:cachix/devenv";

    devenv-root = {
      flake = false;
      url = "file+file:///dev/null";
    };

    dfiles = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:duxlabs-dev/dux-files";
    };

    dgop = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:duxlabs-dev/dux-gop";
    };

    direnv-instant.url = "github:Mic92/direnv-instant";

    disko = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/disko";
    };

    dms = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:duxlabs-dev/dux-shell";
    };

    dms-plugin-registry.url = "github:duxlabs-dev/dux-plugin-registry";
    files.url = "github:sini/files";
    flake-aspects.url = "github:denful/flake-aspects";

    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs";
      url = "github:hercules-ci/flake-parts";
    };

    flake-root.url = "github:srid/flake-root";

    ghostty = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:ghostty-org/ghostty";
    };

    git-hooks-nix.url = "github:cachix/git-hooks.nix";

    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };

    home-manager-stable = {
      inputs.nixpkgs.follows = "nixpkgs-stable";
      url = "github:nix-community/home-manager/release-26.05";
    };

    impermanence = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/impermanence";
    };

    import-tree.url = "github:denful/import-tree";
    lazyvim.url = "github:pfassina/lazyvim-nix";

    llm-agents = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/llm-agents.nix";
    };

    make-shell.url = "github:nicknovitski/make-shell";

    mangowm = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:mangowm/mango";
    };

    mermaid-rs-renderer = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:1jehuang/mermaid-rs-renderer";
    };

    mise-nix.url = "github:wadackel/mise-nix";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";

    neovim-nightly-overlay = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/neovim-nightly-overlay";
    };

    nix-doom-emacs-unstraightened = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:marienz/nix-doom-emacs-unstraightened";
    };

    nix-index-database = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nix-index-database";
    };

    nix-unit.url = "github:nix-community/nix-unit";
    nix-vite-plus.url = "github:ryoppippi/nix-vite-plus";

    nix-vscode-extensions = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nix-vscode-extensions";
    };

    nix2container.url = "github:nlewo/nix2container";

    nixcord = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:4evy/nixcord";
    };

    nixfmt-rs.url = "github:Mic92/nixfmt-rs";
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    nixpkgs-lib.follows = "nixpkgs";
    nixpkgs-stable.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.xz";

    noctalia = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:noctalia-dev/noctalia";
    };

    nur.url = "github:nix-community/NUR";
    pedantix.url = "github:swarsel/pedantix";
    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";

    rust-overlay = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:oxalica/rust-overlay";
    };

    silentSDDM = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:uiriansan/SilentSDDM";
    };

    stylix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/stylix";
    };

    tmux-fzf-links = {
      flake = false;
      url = "github:alberti42/tmux-fzf-links";
    };

    tmux-menus = {
      flake = false;
      url = "github:jaclu/tmux-menus";
    };

    tmux-nerd-font-window-name.url = "github:joshmedeski/tmux-nerd-font-window-name";
    tmux-remux.url = "github:noamsto/tmux-remux";

    tmux-src = {
      flake = false;
      url = "github:tmux/tmux";
    };

    torlink.url = "github:WarlaxZ/torlink";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    tuios.url = "github:Gaurav-Gosain/tuios";

    vim-plugins-kitehost-nvim = {
      flake = false;
      url = "github:selimacerbas/kitehost.nvim";
    };

    vim-plugins-lze = {
      flake = false;
      url = "github:BirdeeHub/lze";
    };

    vim-plugins-lzextras = {
      flake = false;
      url = "github:BirdeeHub/lzextras";
    };

    vim-plugins-mdkite-nvim = {
      flake = false;
      url = "github:selimacerbas/mdkite.nvim";
    };

    vim-plugins-nvim-colorpicker = {
      flake = false;
      url = "github:mikevskater/nvim-colorpicker";
    };

    vim-plugins-nvim-float = {
      flake = false;
      url = "github:mikevskater/nvim-float";
    };

    vim-plugins-oil-git-nvim = {
      flake = false;
      url = "github:malewicz1337/oil-git.nvim";
    };

    vim-plugins-org-nvim = {
      flake = false;
      url = "github:xheisenbugx/org.nvim";
    };

    vim-plugins-showkeys = {
      flake = false;
      url = "github:nvzone/showkeys";
    };

    vim-plugins-tuxedo-nvim = {
      flake = false;
      url = "github:IogaMaster/tuxedo.nvim";
    };

    vim-plugins-wakatime = {
      flake = false;
      url = "github:wakatime/vim-wakatime";
    };

    workmux.url = "github:raine/workmux";

    wrappers = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nix-wrapper-modules";
    };

    yazi-plugin-whoosh = {
      flake = false;
      url = "github:WhoSowSee/whoosh.yazi";
    };

    zen-browser = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:0xc000022070/zen-browser-flake";
    };

    zennotes.url = "github:ZenNotes/zennotes";

    zsh-histdb-src = {
      flake = false;
      url = "github:larkery/zsh-histdb";
    };
  };

  nixConfig = {
    accept-flake-config = true;
    allow-import-from-derivation = true;
    auto-optimise-store = true;

    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.flox.dev"
      "https://numtide.cachix.org"
      "https://cache.numtide.com"
      "https://devenv.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE"
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];

    lazy-trees = true;
    show-trace = true;
    submodules = true;
    use-xdg-base-directories = true;
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
