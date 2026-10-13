{
  self,
  inputs,
  lib,
  ...
}:
{
  # References
  # https://nixos.org/manual/nixpkgs/unstable/#neovim-custom-configuration
  # https://github.com/nix-community/neovim-nightly-overlay
  # https://github.com/lumen-oss/lz.n
  # https://nix-community.github.io/nix-wrapper-modules/wrapperModules/neovim.html
  flake.wrappers.neovim =
    {
      config,
      wlib,
      lib,
      pkgs,
      ...
    }:
    let

      blink-cmp = inputs.blink-cmp.packages.${pkgs.stdenv.hostPlatform.system}.blink-cmp;
      blink-lib = inputs.blink-lib.packages.${pkgs.stdenv.hostPlatform.system}.blink-lib;

      kdl-lsp = pkgs.rustPlatform.buildRustPackage {
        pname = "kdl-lsp";
        version = "0.1.0";
        src = pkgs.fetchFromGitHub {
          owner = "kdl-org";
          repo = "kdl-rs";
          rev = "7de9eb2f4879f3f86157bf2345c93ed52db88e7a";
          hash = "sha256-Fx6yjh/JmCxrQWWkqJRQwCoeWRQ6OZPm3zHpPLaUYMQ=";
        };
        cargoHash = "sha256-lAmfaH3SpX0Al2VuT+V/0K5+KpwV0uIKZV0idoUy08w=";
        buildAndTestSubdir = "tools/kdl-lsp";
      };
    in
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
      config.specs.lzn-auto-require = pkgs.vimPlugins.lzn-auto-require;
      config.specs.rtp = pkgs.vimPlugins.rtp-nvim;

      # https://github.com/lumen-oss/rtp.nvim
      # More Handlers. .
      # https://github.com/BirdeeHub/lzextras

      # -----------------------------------------------------------------------
      # Runtime packages (tools, language servers, formatters, linters)
      # -----------------------------------------------------------------------
      config.runtimePkgs = with pkgs; [
        # CLI tools
        lazygit
        tree-sitter
        ripgrep
        fd
        lua5_1

        # -----------------------------------------------------------------------
        # Language servers, linters, formatters
        # [lsp.lua](../../../config/nvim/lua/plugins/lsp.lua)
        # [lint.lua](../../../config/nvim/lua/plugins/lint.lua)
        # [conform.lua](../../../config/nvim/lua/plugins/conform.lua)
        # -----------------------------------------------------------------------

        # nix
        nixd
        nil
        nixfmt
        statix

        # lua
        lua-language-server
        stylua

        # shell
        bash-language-server
        shfmt
        shellcheck

        # markdown
        marksman
        markdownlint-cli2

        # toml
        taplo

        # yaml
        yaml-language-server
        yamlfmt

        # kdl
        kdlfmt
        kdl-lsp

        # json
        vscode-json-languageserver

        # Web
        emmet-language-server
        beam29Packages.expert
        elixir-ls
        typescript
        oxfmt
        oxlint
        tailwindcss-language-server
        svelte-language-server
        astro-language-server

      ];

      config.specs.general = {
        lazy = true;
        # https://wiki.nixos.org/wiki/Vim#Add_a_new_custom_plugin_to_the_users_packages
        data = with pkgs.vimPlugins; [

          # Language Helpers
          conform-nvim
          nvim-lspconfig
          nvim-lint
          nvim-surround
          nvim-treesitter-textobjects
          nvim-treesitter.withAllGrammars
          nvim-treesitter
          nvim-treesitter-context
          treesj
          SchemaStore-nvim
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
          cord-nvim

          # Navigation & Editing
          flash-nvim
          todo-comments-nvim
          harpoon2
          harpoon-lualine
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
          blink-cmp # Flake input
          blink-lib # Flake input
          blink-compat
          blink-ripgrep-nvim
          blink-emoji-nvim
          blink-nerdfont-nvim
          blink-cmp-env
          blink-cmp-dictionary
          blink-cmp-git
          blink-pairs
          colorful-menu-nvim
          luasnip
          friendly-snippets

          # UI
          bufferline-nvim
          octo-nvim
          lensline-nvim
          gitsigns-nvim
          lualine-nvim
          nvim-web-devicons
          which-key-nvim
          hlchunk-nvim
          render-markdown-nvim

          # AI
          codecompanion-nvim
          # windsurf-nvim
          # sidekick-nvim

          # https://github.com/dmtrKovalenko/fff

          # (pkgs.vimUtils.buildVimPlugin {
          #   pname = "herdr-nvim";
          #   version = "1.2.0";
          #   src = pkgs.fetchFromGitHub {
          #     owner = "ChmaraX";
          #     repo = "herdr-nvim";
          #     rev = "e2ec32e7bbbb1eefd64363414b5806f84eedd6bc";
          #     hash = "sha256-Hk+r5ReArirmjsYOK7BEt8/tj81RmM56SqZSfkYgmcQ=";
          #   };
          #   doCheck = false;
          # })

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

      # -----------------------------------------------------------------------
      # Rich metadata exposed to Lua via nixInfo(nil, "info", ...)
      # -----------------------------------------------------------------------
      config.info =
        let
          extractMeta =
            raw:
            let
              p = raw.data or raw;
              pname =
                if p ? pname && p.pname != null then
                  p.pname
                else if p ? name && p.name != null then
                  p.name
                else
                  null;
            in
            {
              name = pname;
              version = p.version or null;
              rev = if p ? src && p.src ? rev then p.src.rev else null;
              repo =
                if p ? src && p.src ? owner && p.src ? repo then
                  "${p.src.owner}/${p.src.repo}"
                else if p ? src && p.src ? gitRepoUrl then
                  p.src.gitRepoUrl
                else
                  null;
            };
          allPlugins = config.specs.general.data ++ [
            config.specs.colorscheme.data
            (config.specs.lzn.data or config.specs.lzn)
          ];
        in
        {
          flake = {
            rev = self.shortRev or self.dirtyShortRev or "dirty";
            date = self.lastModifiedDate or null;
            nixpkgs_version = pkgs.lib.version;
            system = pkgs.stdenv.hostPlatform.system;
          };
          plugins_meta = lib.pipe allPlugins [
            (map extractMeta)
            (builtins.filter (m: m.name != null))
            (map (m: lib.nameValuePair m.name m))
            builtins.listToAttrs
          ];
          runtime_pkgs = map (p: {
            name = p.pname or p.name;
            version = p.version or null;
          }) config.runtimePkgs;
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
