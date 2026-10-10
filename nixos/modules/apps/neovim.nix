{
  self,
  inputs,
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

      config.binName = lib.mkDefault "nvim";
      config.settings.dont_link = false;

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
      # lz.n comes from nixpkgs (LuaRocks based) - no extra flake inputs.
      # -----------------------------------------------------------------------
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
          lazydev-nvim
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

          nvim-colorizer-lua

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
          luasnip
          friendly-snippets
          lualine-nvim
          gitsigns-nvim
          which-key-nvim
          fidget-nvim
          nvim-lint
          bufferline-nvim
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

          nerdy-nvim

          fff-nvim
          ccc-nvim

          # https://github.com/dmtrKovalenko/fff

          (pkgs.vimUtils.buildVimPlugin {
            pname = "snacks-unicode";
            version = "unstable-2026-10-10";
            src = pkgs.fetchFromGitHub {
              owner = "ecruzolivera";
              repo = "snacks-unicode";
              rev = "2dafb7574ab3d689ed06bb2a41b89c7368fc604b";
              hash = "sha256-6o0DvRqLX06FeTNYe9msuSluTxsiBwU7A2Y3PET3Ztw=";
            };
            doCheck = false;
          })

          (pkgs.vimUtils.buildVimPlugin {
            pname = "emoji.nvim";
            version = "unstable-2026-10-10";
            src = pkgs.fetchFromGitHub {
              owner = "Allaman";
              repo = "emoji.nvim";
              rev = "372cb33e608941d2ddbdb60fc52eb78bfdf62ea2";
              hash = "sha256-Z6njpXPG1AnCh76HKPITF0TA3eIBeP0LWP8rUxgMvjk=";
            };
            doCheck = false;
          })

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

          (pkgs.vimUtils.buildVimPlugin {
            pname = "sidekick.nvim";
            version = "unstable-2026-10-10";
            src = pkgs.fetchFromGitHub {
              owner = "folke";
              repo = "sidekick.nvim";
              rev = "3d80a47e6375f6d647c9695d3afea6fa1b3275df";
              hash = "sha256-YV4QMU2I+6PwTVdjsh/1Z+WTeLW9spgpugccmsqpxRY=";
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
