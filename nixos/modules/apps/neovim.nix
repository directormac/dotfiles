{
  self,
  inputs,
  lib,
  ...
}:
{
  # ===========================================================================
  # Neovim NixOS Module & Wrapper Architecture
  # ===========================================================================
  # References:
  # - Wrapper Modules: https://nix-community.github.io/nix-wrapper-modules/wrapperModules/neovim.html
  # - Neovim Nightly Overlay: https://github.com/nix-community/neovim-nightly-overlay
  # - lze Lazy Loading: https://github.com/BirdeeHub/lze
  # - lzextras Extensions: https://github.com/BirdeeHub/lzextras
  # - Nixpkgs Neovim Config: https://nixos.org/manual/nixpkgs/unstable/#neovim-custom-configuration
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
      # -----------------------------------------------------------------------
      # External Packages & Custom Derivations
      # -----------------------------------------------------------------------
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

      # https://github.com/zFrenesy/vellum.nvim — live markdown preview.
      # Diagrams, display math and non-PNG images are rendered by a Node sidecar
      # in render/ (Puppeteer). Its lazy.nvim build.lua runs `npm ci` and
      # downloads a headless Chrome; we never let that run. Instead the npm deps
      # are built here from the committed lockfile, and Puppeteer is pointed at
      # pkgs.chromium via PUPPETEER_EXECUTABLE_PATH (see config.env below).
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
        # Regenerate with: nix run nixpkgs#prefetch-npm-deps -- <render>/package-lock.json
        npmDepsHash = "sha256-Zcitez2/UGHu4Reux1XwTBwLMzyMDg17Ywa6QXWGTYQ=";
        dontNpmBuild = true;
        # Puppeteer's install script downloads its own browser; skip it and use
        # pkgs.chromium at runtime instead.
        npmFlags = [ "--ignore-scripts" ];
        env.PUPPETEER_SKIP_DOWNLOAD = "true";
        # render/package.json has no "version", so the stock npm install hook's
        # `npm pack`/`npm prune` steps fail. We only need node_modules beside
        # browser.mjs, so copy it out directly (matches browser.lua's lookup).
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
        # lua/vellum/browser.lua looks for the renderer at <plugin>/render/node_modules.
        postInstall = ''
          cp -r ${vellum-render}/lib/node_modules/vellum-render/node_modules \
            $out/render/node_modules
        '';
      };
    in
    {
      imports = [ wlib.wrapperModules.neovim ];

      # -----------------------------------------------------------------------
      # Flake Input Plugins Auto-builder
      # Automatically turns any flake input named `vim-plugins-<name>` into a
      # derivation accessible via `config.nvim-lib.neovimPlugins.<name>`.
      # -----------------------------------------------------------------------
      options.nvim-lib.neovimPlugins = lib.mkOption {
        readOnly = true;
        type = lib.types.attrsOf wlib.types.stringable;
        default = config.nvim-lib.pluginsFromPrefix "vim-plugins-" inputs;
      };

      # Neovim Nightly binary from neovim-nightly-overlay
      config.package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;

      # Binary name exposed on PATH
      config.binName = lib.mkDefault "nvim";

      # The config directory.
      # By default, reads dynamically from the live out-of-store symlink at
      # `vim.fn.stdpath('config')` (or `$NVIM_DEV_CONFIG` when set in dev environments).
      # This enables instant hot-reloading when editing dotfiles without requiring a nix rebuild.
      config.settings.config_directory = lib.mkDefault (
        lib.generators.mkLuaInline "(vim.env.NVIM_DEV_CONFIG or vim.fn.stdpath('config'))"
      );

      # vellum.nvim's Node renderer (render/browser.mjs) launches Puppeteer. It
      # is built without its bundled Chrome, so point it at Nix's Chromium.
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

      # -----------------------------------------------------------------------
      # Plugin Specifications (`config.specs`)
      # Categorized plugin declarations managed by nix-wrapper-modules & lze.
      # -----------------------------------------------------------------------

      # Colorscheme plugin chosen by config.settings.colorscheme
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

      # Core lazy loader engine: lze & lzextras
      config.specs.lze = [
        config.nvim-lib.neovimPlugins.lze
        {
          data = config.nvim-lib.neovimPlugins.lzextras;
          name = "lzextras";
        }
      ];

      # Nix language support tools
      config.specs.nix = {
        data = null;
        runtimePkgs = with pkgs; [
          nixd
          nil
          nixfmt
          statix
        ];
      };

      # Lua language support tools
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
        # Will load after lze
        after = [ "lze" ];
        # Lazy by default
        lazy = true;
        # https://wiki.nixos.org/wiki/Vim#Add_a_new_custom_plugin_to_the_users_packages
        data = with pkgs.vimPlugins; [

          # Override lazy loading for these
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
          blink-cmp # Flake input
          blink-lib # Flake input
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
          vellum-nvim # live markdown preview (Node renderer for diagrams/math/images)

          # AI
          codecompanion-nvim
          # windsurf-nvim
          # sidekick-nvim

        ];

        runtimePkgs = with pkgs; [
          # Copilot LSP
          copilot-language-server

          # CLI tools
          lazygit
          tree-sitter
          ripgrep
          fd
          lua5_1
          nodejs # vellum.nvim renderer (diagrams / math / images)

          # -----------------------------------------------------------------------
          # Language servers, linters, formatters
          # [lsp.lua](../../../config/nvim/lua/plugins/lsp.lua)
          # [lint.lua](../../../config/nvim/lua/plugins/lint.lua)
          # [conform.lua](../../../config/nvim/lua/plugins/conform.lua)
          # -----------------------------------------------------------------------

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

      # -----------------------------------------------------------------------
      # Spec Modifiers (`specMods`) & PATH Collection
      # Extends plugin specifications with a custom `runtimePkgs` field so
      # language servers, formatters, and tools associated with a spec are
      # automatically collected onto PATH only when that spec is enabled.
      # Reference: https://nix-community.github.io/nix-wrapper-modules/neovim.html#tips-and-tricks
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
              A runtimePkgs spec field to put packages on PATH.
              If the spec is disabled, these packages are omitted from the wrapper derivation.
            '';
          };
        };

      # Collect all runtimePkgs defined across active specs into the wrapper PATH
      config.runtimePkgs = config.specCollect (acc: v: acc ++ (v.runtimePkgs or [ ])) [ ];

      options.settings.extraCats = lib.mkOption {
        type = lib.types.attrsOf lib.types.bool;
        default = { };
        description = "Additional categories to expose to Lua via nixInfo.has_cat()";
      };

      # Inform our lua of which top level specs and extra categories are enabled
      options.settings.cats = lib.mkOption {
        readOnly = true;
        type = lib.types.attrsOf lib.types.bool;
        default = (builtins.mapAttrs (_: v: v.enable) config.specs) // config.settings.extraCats;
      };

      # build plugins from inputs set
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
