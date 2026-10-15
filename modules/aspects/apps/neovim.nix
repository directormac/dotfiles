# Neovim Nightly & Modular Lua Configuration Aspect
{
  core,
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs = {
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

    vim-plugins-lze = {
      url = "github:BirdeeHub/lze";
      flake = false;
    };
    vim-plugins-lzextras = {
      url = "github:BirdeeHub/lzextras";
      flake = false;
    };
    vim-plugins-oil-git-nvim = {
      url = "github:malewicz1337/oil-git.nvim";
      flake = false;
    };
    vim-plugins-nvim-colorpicker = {
      url = "github:mikevskater/nvim-colorpicker";
      flake = false;
    };
    vim-plugins-wakatime = {
      url = "github:wakatime/vim-wakatime";
      flake = false;
    };
    vim-plugins-nvim-float = {
      url = "github:mikevskater/nvim-float";
      flake = false;
    };
    vim-plugins-tuxedo-nvim = {
      url = "github:IogaMaster/tuxedo.nvim";
      flake = false;
    };
    vim-plugins-showkeys = {
      url = "github:nvzone/showkeys";
      flake = false;
    };
  };

  core.neovim = {
    homeManager =
      {
        config,
        pkgs,
        user,
        ...
      }:
      let
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
        neovimPkg =
          if inputs ? neovim-nightly-overlay then
            (inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim or pkgs.neovim-unwrapped)
          else
            pkgs.neovim-unwrapped;
      in
      {
        home.packages = [ neovimPkg ];
        home.sessionVariables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };

        home.file.".config/nvim".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/nvim";
      };

    persistHome.directories = [
      ".local/share/nvim"
      ".local/state/nvim"
    ];
  };

  # Attach to workstation aspect
  core.workstation.provides.to-users.includes = [
    core.neovim
  ];
}
