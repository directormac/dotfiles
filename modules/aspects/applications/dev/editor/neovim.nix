# Neovim Nightly & Modular Lua Wrapper Aspect
{
  lib,
  inputs,
  self,
  ...
}:
{
  flake-file.inputs = {
    blink-cmp = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:saghen/blink.cmp";
    };

    blink-lib = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:saghen/blink.lib";
    };

    neovim-nightly-overlay = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/neovim-nightly-overlay";
    };

    vim-plugins-lze = {
      flake = false;
      url = "github:BirdeeHub/lze";
    };

    vim-plugins-lzextras = {
      flake = false;
      url = "github:BirdeeHub/lzextras";
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
  };

  den.aspects.applications.dev.editor.neovim = {
    nixos =
      { pkgs, ... }:
      {
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

        imports = [ self.wrappers.neovim.install ];
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
        home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/nvim";

        home.sessionVariables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };

        imports = [ self.wrappers.neovim.install ];
        wrappers.neovim.enable = true;

        xdg.desktopEntries = {
          neovim = {
            categories = [
              "Utility"
              "TextEditor"
              "Development"
            ];

            comment = "Manage text files";
            exec = "ghostty --class=com.neovim.editor -e nvim %F";
            genericName = "Text Editor";
            icon = "nvim";

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

            name = "Neovim";
            terminal = false;
            type = "Application";
          };

          nvim = {
            settings = {
              NoDisplay = "true";
            };

            exec = "nvim %F";
            name = "Neovim";
            type = "Application";
          };
        };
      };

    persistHome.directories = [
      ".local/share/nvim"
      ".local/state/nvim"
    ];
  };

  # ===========================================================================
  # Neovim NixOS Module & Wrapper Architecture
  # ===========================================================================
  flake.wrappers.neovim =
    {
      config,
      lib,
      pkgs,
      options,
      wlib,
      ...
    }:
    let
      blink-cmp = inputs.blink-cmp.packages.${pkgs.stdenv.hostPlatform.system}.blink-cmp;
      blink-lib = inputs.blink-lib.packages.${pkgs.stdenv.hostPlatform.system}.blink-lib;
      # Custom build of kdl-lsp from GitHub
      kdl-lsp = pkgs.rustPlatform.buildRustPackage {
        buildAndTestSubdir = "tools/kdl-lsp";
        cargoHash = "sha256-lAmfaH3SpX0Al2VuT+V/0K5+KpwV0uIKZV0idoUy08w=";
        pname = "kdl-lsp";

        src = pkgs.fetchFromGitHub {
          hash = "sha256-Fx6yjh/JmCxrQWWkqJRQwCoeWRQ6OZPm3zHpPLaUYMQ=";
          owner = "kdl-org";
          repo = "kdl-rs";
          rev = "7de9eb2f4879f3f86157bf2345c93ed52db88e7a";
        };

        version = "0.1.0";
      };
      vellum-nvim = pkgs.vimUtils.buildVimPlugin {
        doCheck = false;
        pname = "vellum.nvim";

        postInstall = ''
          cp -r ${vellum-render}/lib/node_modules/vellum-render/node_modules \
            $out/render/node_modules
        '';

        src = vellumSrc;
        version = "unstable-2026-10-13";
      };
      vellum-render = pkgs.buildNpmPackage {
        dontNpmBuild = true;
        env.PUPPETEER_SKIP_DOWNLOAD = "true";

        installPhase = ''
          runHook preInstall
          mkdir -p $out/lib/node_modules/vellum-render
          cp -r node_modules $out/lib/node_modules/vellum-render/node_modules
          runHook postInstall
        '';

        npmDepsHash = "sha256-Zcitez2/UGHu4Reux1XwTBwLMzyMDg17Ywa6QXWGTYQ=";
        npmFlags = [ "--ignore-scripts" ];
        pname = "vellum-render";
        src = "${vellumSrc}/render";
        version = "unstable-2026-10-13";
      };
      vellumSrc = pkgs.fetchFromGitHub {
        hash = "sha256-WKbnohPgZOQd1klxXXDGKbZeMSNQmjEuYTi+sL+zMgA=";
        owner = "zFrenesy";
        repo = "vellum.nvim";
        rev = "910b79e76f5a3389e55a64da9b6816cb9e89a64e";
      };
    in
    {
      imports = [ wlib.wrapperModules.neovim ];

      options.nvim-lib.neovimPlugins = lib.mkOption {
        default = config.nvim-lib.pluginsFromPrefix "vim-plugins-" inputs;
        readOnly = true;
        type = lib.types.attrsOf wlib.types.stringable;
      };

      options.nvim-lib.pluginsFromPrefix = lib.mkOption {
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

        readOnly = true;
        type = lib.types.raw;
      };

      options.settings.cats = lib.mkOption {
        default = (builtins.mapAttrs (_: v: v.enable) config.specs) // config.settings.extraCats;
        readOnly = true;
        type = lib.types.attrsOf lib.types.bool;
      };

      options.settings.colorscheme = lib.mkOption {
        default = "catppuccin";
        description = "Colorscheme to load (drives which plugin gets installed).";
        type = lib.types.str;
      };

      options.settings.dev = lib.mkOption {
        default = false;
        description = "Read the config directory live from the current working directory for quick iteration.";
        type = lib.types.bool;
      };

      options.settings.extraCats = lib.mkOption {
        default = { };
        description = "Additional categories to expose to Lua via nixInfo.has_cat()";
        type = lib.types.attrsOf lib.types.bool;
      };

      options.settings.profiler = lib.mkOption {
        default = false;
        description = "Enable snacks.nvim startup profiler via wrapper environment.";
        type = lib.types.bool;
      };

      config.binName = lib.mkDefault "nvim";
      config.env.PROFILER = lib.mkIf config.settings.profiler "1";
      config.env.PUPPETEER_EXECUTABLE_PATH = "${pkgs.chromium}/bin/chromium";

      config.info =
        let
          allPlugins = lib.flatten [
            config.specs.general.data
            config.specs.colorscheme.data
            (config.specs.lze.data or config.specs.lze)
            (config.specs.lua.data or [ ])
          ];
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

              repo =
                if p ? src && p.src ? owner && p.src ? repo then
                  "${p.src.owner}/${p.src.repo}"
                else if p ? src && p.src ? gitRepoUrl then
                  p.src.gitRepoUrl
                else
                  null;

              rev = if p ? src && p.src ? rev then p.src.rev else null;
              version = p.version or null;
            };
        in
        {
          flake = {
            date = self.lastModifiedDate or null;
            nixpkgs_version = pkgs.lib.version;
            rev = self.shortRev or self.dirtyShortRev or "dirty";
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

      config.package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
      config.runtimePkgs = config.specCollect (acc: v: acc ++ (v.runtimePkgs or [ ])) [ ];

      config.settings.config_directory = lib.mkDefault (
        lib.generators.mkLuaInline "(vim.env.NVIM_DEV_CONFIG or vim.fn.stdpath('config'))"
      );

      config.specMods =
        _:
        {
          options.runtimePkgs = options.runtimePkgs // {
            description = ''
              A runtimePkgs spec field to put packages on PATH.
              If the spec is disabled, these packages are omitted from the wrapper derivation.
            '';
          };
        };

      config.specs.colorscheme = {
        data = builtins.getAttr config.settings.colorscheme (
          with pkgs.vimPlugins;
          {
            catppuccin = catppuccin-nvim;
            onedark = onedarkpro-nvim;
            tokyonight = tokyonight-nvim;
          }
        );

        lazy = true;
      };

      config.specs.general = {
        after = [ "lze" ];

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

        lazy = true;

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

      config.specs.lua = {
        after = [ "general" ];

        data = with pkgs.vimPlugins; [
          lazydev-nvim
        ];

        lazy = true;

        runtimePkgs = with pkgs; [
          lua-language-server
          stylua
        ];
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
}
