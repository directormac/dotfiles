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

      config.binName = lib.mkDefault "neovim";

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
          ripgrep
          fd
        ];
        lazy = true;
        data = with pkgs.vimPlugins; [
          plenary-nvim

          snacks-nvim
          oil-nvim
          (oil-git-nvim.overrideAttrs (_: {
            pname = "oil-git.nvim";
            version = "unstable-2026-10-10";
            src = pkgs.fetchFromGitHub {
              owner = "malewicz1337";
              repo = "oil-git.nvim";
              rev = "8bab14df0b7db7a62fa75c8978d6181daed2f0a2";
              hash = "sha256-JqJ1t4Zk4ROUXnFvk63hJw18nq7rXQU5NxnP4HHWXpU=";
            };
          }))
          oil-lsp-diagnostics-nvim
          persistence-nvim

          # vim-sleuth
          mini-nvim
          nvim-web-devicons
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
          zen-mode-nvim
          yanky-nvim
          otter-nvim
          # windsurf-nvim

          nvim-treesitter-textobjects
          nvim-treesitter.withAllGrammars

          # Navigation & Editing
          flash-nvim
          todo-comments-nvim
          grug-far-nvim
          edgy-nvim

          # UI & Notifications
          noice-nvim
          nui-nvim
          nvim-notify

          # Debug Adapter Protocol (DAP)
          nvim-dap
          nvim-dap-ui
          nvim-nio
          nvim-dap-virtual-text
          one-small-step-for-vimkind
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
      # NOTE: cannot symlink ~/.config/nvim at the whole-directory level while
      # lazyvim-nix enables `programs.neovim`, because that module also writes
      # `~/.config/nvim/init.lua` (the rplugin manifest). Home Manager then
      # fails with "Error installing file '.config/nvim/init.lua' outside $HOME"
      # and the whole generation fails to build. Uncomment once lazyvim is gone.
      home.file.".config/nvim-dev".source =
        config.lib.file.mkOutOfStoreSymlink "${config.preferences.dotsConfigPath}/nvim";
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
          binName = "nvim-dev";
          env.NVIM_APPNAME = "nvim-dev";
          settings.config_directory = lib.generators.mkLuaInline "vim.fn.stdpath('config')";
        }).wrap
          { inherit pkgs; };
    };
}
