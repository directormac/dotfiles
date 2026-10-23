# Neovim Nightly & Modular Lua Wrapper Aspect
{
  lib,
  den,
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

    mermaid-rs-renderer = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:1jehuang/mermaid-rs-renderer";
    };

    neovim-nightly-overlay = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/neovim-nightly-overlay";
    };

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

  };

  den.aspects.applications.dev.editor.neovim = {
    includes = with den.aspects.applications.dev; [
      editor.lazyvim
      editor.neovim-mdkite
      editor.neovim-org
      lang.nix
      lang.lua
      lang.shell
      lang.markdown
      lang.data
      lang.kdl
      lang.node
      lang.elixir
    ];

    nixos =
      { pkgs, ... }:
      {
        environment.sessionVariables = {
          EDITOR = "nvim";
        };

        environment.systemPackages = with pkgs; [
          tree-sitter
        ];

        imports = [ self.wrappers.neovim.install ];
      };

    homeManager =
      {
        ...
      }:
      {
        home.file.".config/nvim".source = ../../../../../config/nvim;

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

    devenv =
      { pkgs, ... }:
      {
        env.PROFILER = "1";

        packages = [
          (
            (self.wrappers.neovim.apply {
              settings.config_directory = lib.generators.mkLuaInline "((vim.env.DEVENV_ROOT or vim.env.PWD) .. '/config/nvim')";
              binName = "nvim";
            }).wrap
            { inherit pkgs; }
          )
        ];
      };

    persistHome.directories = [
      ".local/share/nvim"
      ".local/state/nvim"
      ".wakatime"
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

      config.specMods = _: {
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
        # Handlers
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

          # Tree-sitter grammar for tmux configuration files. It is not
          # shipped by nixpkgs, so it is built here. `lazy = false` puts it
          # into the `start` directory of the packpath, so that
          # `vim.treesitter.language.add('tmux')` finds `parser/tmux.so`.
          # It is used for `*.tmux.conf` files and for the `# tmux` injections
          # of the tmux aspect (see
          # `modules/aspects/applications/dev/mux/tmux.nix`).
          {
            data = pkgs.neovimUtils.grammarToPlugin (
              pkgs.tree-sitter.buildGrammar {
                generate = true;
                language = "tmux";

                src = pkgs.fetchFromGitHub {
                  hash = "sha256-OifdD2XEe9GMvvj8eU83SW3prJc7f+lIRcfBPpsGAsI=";
                  owner = "Freed-Wu";
                  repo = "tree-sitter-tmux";
                  rev = "111108ae48a722adc31c96c55e5a5245e0c4b4e6";
                };

                version = "0.1.5";
              }
            );

            lazy = false;
          }

          # Language Helpers
          conform-nvim
          nvim-lspconfig
          nvim-lint
          nvim-surround
          nvim-autopairs
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
          obsidian-nvim
          config.nvim-lib.neovimPlugins.wakatime
          config.nvim-lib.neovimPlugins.org-nvim

          # Navigation & Editing
          hardtime-nvim
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
          config.nvim-lib.neovimPlugins.mdkite-nvim
          config.nvim-lib.neovimPlugins.kitehost-nvim

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
          mermaid-cli
          mdcat
        ];
      };

      config.specs.lze = [
        config.nvim-lib.neovimPlugins.lze
        {
          data = config.nvim-lib.neovimPlugins.lzextras;
          name = "lzextras";
        }
      ];

    };

}
