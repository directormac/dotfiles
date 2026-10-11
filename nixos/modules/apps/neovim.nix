{
  self,
  inputs,
  lib,
  ...
}:
{
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
      config.binName = lib.mkDefault "nvim";
      config.settings.dont_link = false;
      config.settings.config_directory = lib.mkDefault ../../../config/nvim;

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

      config.specs.lzn = pkgs.vimPlugins.lz-n;

      # -----------------------------------------------------------------------
      # Runtime packages (tools, language servers, formatters, linters)
      # -----------------------------------------------------------------------
      config.runtimePkgs = with pkgs; [
        # CLI tools
        lazygit
        tree-sitter
        ripgrep
        fd
        cargo

        # Language servers, linters, formatters
        nixd
        nixfmt
        nil
        lua-language-server
        stylua
        bash-language-server
        shfmt
        shellcheck
        rust-analyzer
        cargo
        rustc
        rustfmt
        beam29Packages.expert
        elixir-ls
        typescript
        tailwindcss-language-server
        marksman
        svelte-language-server
        astro-language-server
      ];

      config.specs.general = {
        lazy = true;
        data = with pkgs.vimPlugins; [

          # Language Helpers
          conform-nvim
          nvim-lspconfig
          nvim-lint
          nvim-surround
          nvim-treesitter-textobjects
          nvim-treesitter.withAllGrammars
          otter-nvim

          # Debug Adapter Protocol (DAP)
          nvim-dap
          nvim-dap-ui
          nvim-nio
          nvim-dap-virtual-text
          one-small-step-for-vimkind

          # Utils
          lazydev-nvim
          mini-nvim
          noice-nvim
          nui-nvim
          plenary-nvim
          persistence-nvim
          snacks-nvim
          vim-startuptime

          # Navigation & Editing
          flash-nvim
          todo-comments-nvim
          grug-far-nvim
          edgy-nvim
          yanky-nvim
          fff-nvim
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
          (pkgs.vimUtils.buildVimPlugin {
            pname = "nvim-colorpicker";
            version = "unstable-2026-10-10";
            src = pkgs.fetchFromGitHub {
              owner = "mikevskater";
              repo = "nvim-colorpicker";
              rev = "88f6aeac944570ebfb97ac67c9fea27a73ea0429";
              hash = "sha256-OfJuhBFel+lEmm11QCXKGayFx47mRJatqMFOEbbqz9o=";
            };
            doCheck = false;
          })

          # Completion
          (inputs.blink-cmp.packages.${pkgs.stdenv.hostPlatform.system}.blink-cmp)
          (inputs.blink-lib.packages.${pkgs.stdenv.hostPlatform.system}.blink-lib)
          blink-compat
          blink-ripgrep-nvim
          blink-emoji-nvim
          blink-nerdfont-nvim
          blink-cmp-env
          blink-cmp-dictionary
          blink-pairs
          colorful-menu-nvim
          luasnip
          friendly-snippets

          # UI
          bufferline-nvim
          gitsigns-nvim
          lualine-nvim
          nvim-web-devicons
          which-key-nvim
          render-markdown-nvim

          # AI
          codecompanion-nvim
          # sidekick-nvim
          # windsurf-nvim

          # https://github.com/dmtrKovalenko/fff

          (pkgs.vimUtils.buildVimPlugin {
            pname = "nvim-float";
            version = "unstable-2026-10-10";
            src = pkgs.fetchFromGitHub {
              owner = "mikevskater";
              repo = "nvim-float";
              rev = "ae790c0a96fcf0c5267371bff04b2fc4542fd643";
              hash = "sha256-5rV35/k9TXiprjpEWH3j+/FKryfwijR4GN1mCQBPVhU=";
            };
            doCheck = false;
          })

          (pkgs.vimUtils.buildVimPlugin {
            pname = "tuxedo.nvim";
            version = "unstable-2026-10-10";
            src = pkgs.fetchFromGitHub {
              owner = "IogaMaster";
              repo = "tuxedo.nvim";
              rev = "65650b0ae3b1c3755a43306b07ada13bd78d47ac";
              hash = "sha256-e8Vk2QvMNDDpYCiTWwm5IgDlDhVKj2g+kNHpLbkYGx4=";
            };
            doCheck = false;
          })

          (pkgs.vimUtils.buildVimPlugin {
            pname = "showkeys";
            version = "unstable-2026-10-10";
            src = pkgs.fetchFromGitHub {
              owner = "nvzone";
              repo = "showkeys";
              rev = "cb0a50296f11f1e585acffba8c253b9e8afc1f84";
              hash = "sha256-mn/SBtk9YbYZRTJZ054IVsSVOlrry5gsHOXQEnd3b7M=";
            };
            doCheck = false;
          })

        ];
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

      home.file.".config/nvim".source =
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
          binName = "nvim";
          settings.config_directory = lib.generators.mkLuaInline "(vim.env.NVIM_DEV_CONFIG or vim.fn.stdpath('config'))";
        }).wrap
          { inherit pkgs; };
    };
}
