{
  inputs,
  self,
  lib,
  ...
}:
{
  # ---------------------------------------------------------------------------
  # Main wrapped Neovim (nightly + nix-wrapper-modules)
  #
  # Declared once here; the flake-parts module (imported in flake-parts.nix)
  # turns this into:
  #   outputs.wrappers.neovim
  #   outputs.wrapperModules.neovim
  #   packages.<system>.neovim
  # ---------------------------------------------------------------------------
  flake.wrappers.neovim =
    {
      config,
      wlib,
      lib,
      pkgs,
      options,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.neovim ];

      # Nightly Neovim via the overlay input (verified: .packages.<sys>.neovim).
      config.package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;

      # The config directory. `mkDefault` so the devshell variant can override it.
      config.settings.config_directory = lib.mkDefault ../../../config/nvim;

      config.binName = "neovim";

      config.settings.dont_link = true;

      # -----------------------------------------------------------------------
      # User-facing options -> exposed to Lua via the generated info plugin.
      # Read in Lua with:
      #   nixInfo(nil, "settings", "colorscheme")
      #   nixInfo(false, "settings", "cats", "lua")
      # -----------------------------------------------------------------------
      options.settings.colorscheme = lib.mkOption {
        type = lib.types.str;
        default = "catppuccin";
        description = "Colorscheme to load (drives which plugin gets installed).";
      };

      # Colourscheme plugin chosen by the option above.
      config.specs.colorscheme = {
        lazy = true;
        data = builtins.getAttr config.settings.colorscheme (
          with pkgs.vimPlugins;
          {
            catppuccin = catppuccin-nvim;
            tokyonight = tokyonight-nvim;
            onedark = onedarkpro-nvim;
            moonfly = vim-moonfly-colors;
          }
        );
      };

      # -----------------------------------------------------------------------
      # lze + lzextras come from nixpkgs (LuaRocks based) - no extra flake inputs.
      # -----------------------------------------------------------------------
      config.specs.lze = [
        pkgs.vimPlugins.lze
        {
          data = pkgs.vimPlugins.lzextras;
          name = "lzextras";
        }
      ];

      # -----------------------------------------------------------------------
      # Language groups. in the Lua specs
      # gate LSP setup on whether these top level specs are enabled.
      # -----------------------------------------------------------------------
      config.specs.nix = {
        data = null;
        runtimePkgs = with pkgs; [
          nixd
          nixfmt
        ];
      };

      config.specs.lua = {
        after = [ "general" ];
        lazy = true;
        data = with pkgs.vimPlugins; [ lazydev-nvim ];
        runtimePkgs = with pkgs; [
          lua-language-server
          stylua
        ];
      };

      config.specs.general = {
        after = [ "lze" ];
        runtimePkgs = with pkgs; [
          lazygit
          tree-sitter
        ];
        lazy = true;
        data = with pkgs.vimPlugins; [
          {
            data = vim-sleuth;
            lazy = false;
          }
          snacks-nvim
          oil-nvim

          nvim-lspconfig
          nvim-surround
          vim-startuptime
          blink-cmp
          blink-compat
          cmp-cmdline
          colorful-menu-nvim
          lualine-nvim
          gitsigns-nvim
          which-key-nvim
          fidget-nvim
          nvim-lint
          conform-nvim
          nvim-treesitter-textobjects
          nvim-treesitter.withAllGrammars
        ];
      };

      # -----------------------------------------------------------------------
      # Tips & tricks: add a per-spec `runtimePkgs` field.
      # -----------------------------------------------------------------------
      config.specMods =
        {
          parentSpec ? null,
          parentOpts ? null,
          parentName ? null,
          config,
          ...
        }:
        {
          options.runtimePkgs = options.runtimePkgs // {
            description = ''
              A runtimePkgs spec field to put packages on the PATH.
              If the spec is disabled, this value will not be included in the
              resulting neovim derivation.
            '';
          };
        };
      config.runtimePkgs = config.specCollect (acc: v: acc ++ (v.runtimePkgs or [ ])) [ ];

      # Expose which top level spec groups are enabled to Lua (`settings.cats`).
      options.settings.cats = lib.mkOption {
        readOnly = true;
        type = lib.types.attrsOf lib.types.bool;
        default = builtins.mapAttrs (_: v: v.enable) config.specs;
      };
    };

  # ---------------------------------------------------------------------------
  # Install modules. flake-parts gives each `flake.wrappers.<name>` a `.install`.
  # ---------------------------------------------------------------------------
  flake.homeModules.neovim =
    { config, ... }:
    {
      imports = [ self.wrappers.neovim.install ];

      wrappers.neovim.enable = true;

      # Point ~/.config/nvim at the live repo checkout. The production wrapper
      # links its own in-store config and blocks stdpath('config'), so this is
      # only actually read by the dev variant (vim.fn.stdpath('config')).
      # home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink ../../../config/nvim;
    };

  flake.nixosModules.neovim = {
    imports = [ self.wrappers.neovim.install ];
  };

  # ---------------------------------------------------------------------------
  # Dev variant built on demand by the devshell:
  # loads the live repo config dir for hot reload.
  #   ((config.flake.wrappers.neovim.apply {...}).wrap { inherit pkgs; })
  # (kept out of `flake.wrappers` on purpose so `packages.*.*` stays production)
  # ---------------------------------------------------------------------------
  perSystem =
    { pkgs, ... }:
    {
      packages.nvim-dev =
        (self.wrappers.neovim.apply {
          settings.config_directory = lib.generators.mkLuaInline "vim.fn.stdpath('config')";
        }).wrap
          { inherit pkgs; };
    };
}
