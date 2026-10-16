# Neovim Nightly & Modular Lua Wrapper Aspect
{
  self,
  den,
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

  # ===========================================================================
  # Neovim NixOS Module & Wrapper Architecture
  # ===========================================================================
  flake.wrappers.neovim =
    {
      config,
      wlib,
      lib,
      pkgs,
      options,
      ...
    }:
    let
      blink-cmp = inputs.blink-cmp.packages.${pkgs.stdenv.hostPlatform.system}.blink-cmp;
      blink-lib = inputs.blink-lib.packages.${pkgs.stdenv.hostPlatform.system}.blink-lib;

      # Custom build of kdl-lsp from GitHub
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

      vellumSrc = pkgs.fetchFromGitHub {
        owner = "zFrenesy";
        repo = "vellum.nvim";
        rev = "910b79e76f5a3389e55a64da9b6816cb9e89a64e";
        hash = "sha256-WKbnohPgZOQd1klxXXDGKbZeMSNQmjEuYTi+sL+zMgA=";
      };

      vellum-render = pkgs.buildNpmPackage {
        pname = "vellum-render";
        version = "unstable-2026-10-13";
        src = "${vellumSrc}/render";
        npmDepsHash = "sha256-Zcitez2/UGHu4Reux1XwTBwLMzyMDg17Ywa6QXWGTYQ=";
        dontNpmBuild = true;
        npmFlags = [ "--ignore-scripts" ];
        env.PUPPETEER_SKIP_DOWNLOAD = "true";
        installPhase = ''
          runHook preInstall
          mkdir -p $out/lib/node_modules/vellum-render
          cp -r node_modules $out/lib/node_modules/vellum-render/node_modules
          runHook postInstall
        '';
      };

      vellum-nvim = pkgs.vimUtils.buildVimPlugin {
        pname = "vellum.nvim";
        version = "unstable-2026-10-13";
        src = vellumSrc;
        doCheck = false;
        postInstall = ''
          cp -r ${vellum-render}/lib/node_modules/vellum-render/node_modules \
            $out/render/node_modules
        '';
      };
    in
    {
      imports = [ wlib.wrapperModules.neovim ];

      options.nvim-lib.neovimPlugins = lib.mkOption {
        readOnly = true;
        type = lib.types.attrsOf wlib.types.stringable;
        default = config.nvim-lib.pluginsFromPrefix "vim-plugins-" inputs;
      };

      config.package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;

      config.binName = lib.mkDefault "nvim";

      config.settings.config_directory = lib.mkDefault (
        lib.generators.mkLuaInline "(vim.env.NVIM_DEV_CONFIG or vim.fn.stdpath('config'))"
      );

      config.env.PUPPETEER_EXECUTABLE_PATH = "${pkgs.chromium}/bin/chromium";

      options.settings.dev = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Read the config directory live from the current working directory for quick iteration.";
      };

      options.settings.profiler = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable snacks.nvim startup profiler via wrapper environment.";
      };
      config.env.PROFILER = lib.mkIf config.settings.profiler "1";

      options.settings.colorscheme = lib.mkOption {
        type = lib.types.str;
        default = "catppuccin";
        description = "Colorscheme to load (drives which plugin gets installed).";
      };

      config.specs.colorscheme = {
        lazy = true;
        data = builtins.getAttr config.settings.colorscheme (
          with pkgs.vimPlugins;
          {
            catppuccin = catppuccin-nvim;
            tokyonight = tokyonight-nvim;
            onedark = onedarkpro-nvim;
          }
        );
      };

      config.specs.lze = [
        config.nvim-lib.neovimPlugins.lze
        {
          data = config.nvim-lib.neovimPlugins.lzextras;
          name = "lzextras";
        }
      ];

      config.specs.nix = {
        data = null;
        runtimePkgs = with pkgs; [
          nixd
          nil
          nixfmt
          statix
        ];
      };

      config.specs.lua = {
        after = [ "general" ];
        lazy = true;
        data = with pkgs.vimPlugins; [
          lazydev-nvim
        ];
        runtimePkgs = with pkgs; [
          lua-language-server
          stylua
        ];
      };

      config.specs.general = {
        after = [ "lze" ];
        lazy = true;
        data = with pkgs.vimPlugins; [
          {
            data = snacks-nvim;
            lazy = false;
          }
          {
            data = rtp-nvim;
            lazy = false;
          }
          {
            data = nvim-web-devicons;
            lazy = false;
          }

          # Language Helpers
          conform-nvim
          nvim-lspconfig
          nvim-lint
          nvim-surround
          nvim-treesitter-context
          nvim-treesitter-textobjects
          nvim-treesitter.withAllGrammars
          otter-nvim
          SchemaStore-nvim
          treesj

          # Debug Adapter Protocol (DAP)
          nvim-dap
          nvim-dap-ui
          nvim-nio
          nvim-dap-virtual-text
          one-small-step-for-vimkind

          # Utils
          mini-nvim
          noice-nvim
          nui-nvim
          plenary-nvim
          persistence-nvim
          vim-startuptime
          cord-nvim
          config.nvim-lib.neovimPlugins.wakatime

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
          oil-lsp-diagnostics-nvim
          config.nvim-lib.neovimPlugins.oil-git-nvim
          config.nvim-lib.neovimPlugins.nvim-colorpicker
          config.nvim-lib.neovimPlugins.tuxedo-nvim

          # Completion
          blink-cmp
          blink-lib
          blink-compat
          blink-copilot
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
          which-key-nvim
          hlchunk-nvim
          render-markdown-nvim
          config.nvim-lib.neovimPlugins.nvim-float
          config.nvim-lib.neovimPlugins.showkeys
          vellum-nvim

          # AI
          codecompanion-nvim
        ];

        runtimePkgs = with pkgs; [
          copilot-language-server

          lazygit
          tree-sitter
          ripgrep
          fd
          lua5_1
          nodejs

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
      };

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
              A runtimePkgs spec field to put packages on PATH.
              If the spec is disabled, these packages are omitted from the wrapper derivation.
            '';
          };
        };

      config.runtimePkgs = config.specCollect (acc: v: acc ++ (v.runtimePkgs or [ ])) [ ];

      options.settings.extraCats = lib.mkOption {
        type = lib.types.attrsOf lib.types.bool;
        default = { };
        description = "Additional categories to expose to Lua via nixInfo.has_cat()";
      };

      options.settings.cats = lib.mkOption {
        readOnly = true;
        type = lib.types.attrsOf lib.types.bool;
        default = (builtins.mapAttrs (_: v: v.enable) config.specs) // config.settings.extraCats;
      };

      options.nvim-lib.pluginsFromPrefix = lib.mkOption {
        type = lib.types.raw;
        readOnly = true;
        default =
          prefix: inputs:
          lib.pipe inputs [
            builtins.attrNames
            (builtins.filter (s: lib.hasPrefix prefix s))
            (map (
              input:
              let
                name = lib.removePrefix prefix input;
              in
              {
                inherit name;
                value = config.nvim-lib.mkPlugin name inputs.${input};
              }
            ))
            builtins.listToAttrs
          ];
      };

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
          allPlugins = lib.flatten [
            config.specs.general.data
            config.specs.colorscheme.data
            (config.specs.lze.data or config.specs.lze)
            (config.specs.lua.data or [ ])
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
          runtime_pkgs = map (
            p:
            let
              drv = p.data or p;
            in
            {
              name = drv.pname or drv.name or null;
              version = drv.version or null;
            }
          ) config.runtimePkgs;
        };
    };

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

  den.aspects.applications.dev.editor.neovim = {
    nixos =
      { pkgs, ... }:
      {
        imports = [ self.wrappers.neovim.install ];

        environment.sessionVariables = {
          EDITOR = "nvim";
        };

        environment.systemPackages =
          with pkgs;
          [
            tree-sitter
            nixfmt
            stylua
            lua-language-server
            bash-language-server
            nixd
            nil
          ]
          ++ lib.optionals (pkgs ? nur && pkgs.nur ? repos && pkgs.nur.repos ? Freed-Wu) [
            pkgs.nur.repos.Freed-Wu.tree-sitter-tmux
            pkgs.nur.repos.Freed-Wu.tmux-language-server
            pkgs.nur.repos.Freed-Wu.termux-language-server
          ];
      };

    homeManager =
      {
        config,
        user,
        ...
      }:
      let
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
      in
      {
        imports = [ self.wrappers.neovim.install ];

        wrappers.neovim.enable = true;

        home.sessionVariables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };

        home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/nvim";

        xdg.desktopEntries = {
          neovim = {
            name = "Neovim";
            genericName = "Text Editor";
            comment = "Manage text files";
            exec = "ghostty --class=com.neovim.editor -e nvim %F";
            terminal = false;
            type = "Application";
            icon = "nvim";
            categories = [
              "Utility"
              "TextEditor"
              "Development"
            ];
            mimeType = [
              "text/plain"
              "text/x-chdr"
              "text/x-csrc"
              "text/x-c++hdr"
              "text/x-c++src"
              "text/csv"
              "application/json"
              "application/x-zerosize"
            ];
          };

          nvim = {
            name = "Neovim";
            exec = "nvim %F";
            type = "Application";
            settings = {
              NoDisplay = "true";
            };
          };
        };
      };

    persistHome.directories = [
      ".local/share/nvim"
      ".local/state/nvim"
    ];
  };
}
