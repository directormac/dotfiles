{ inputs, lib, ... }: {
  flake.homeModules.lazyvim =
    {
      pkgs,
      config,
      ...
    }:
    {
      imports = [ inputs.lazyvim.homeManagerModules.default ];

      # See  https://github.com/pfassina/lazyvim-nix/wiki/Troubleshooting
      programs.lazyvim = {
        enable = true;
        appName = "lazyvim";

        # See https://github.com/pfassina/lazyvim-nix/wiki/Plugin-Sourcing-Strategy#plugin-sourcing-strategy
        pluginSource = "nixpkgs";
        ignoreBuildNotifications = true; # Suppress build-time warnings

        # See https://github.com/pfassina/lazyvim-nix/blob/main/data/extras.json
        extras = {

          ai = {
            codeium.enable = true;
          };

          ui = {
            edgy.enable = true;
          };

          editor = {
            # aerial.enable = true;
            harpoon2.enable = true;
            snacks-explorer.enable = true;
            snacks-picker.enable = true;
          };

          dap = {
            core.enable = true;
          };

          coding = {
            # Blink is added by default
            luasnip.enable = true;
            mini-surround.enable = true;
            mini-comment.enable = true;
            yanky.enable = true;
          };

          lang = {

            nix = {
              enable = true;
              installDependencies = true;
              installRuntimeDependencies = true;
            };

            json = {
              enable = true;
              installDependencies = true;
              installRuntimeDependencies = true;
            };

            toml = {
              enable = true;
              installDependencies = true;
              installRuntimeDependencies = true;
            };

            rust = {
              enable = true;
              installDependencies = true;
              installRuntimeDependencies = true;
            };

            elixir = {
              enable = true;
              installDependencies = true;
              installRuntimeDependencies = true;
            };

            git = {
              enable = true;
              installDependencies = true;
              installRuntimeDependencies = true;
            };

            sql = {
              enable = true;
              installDependencies = true;
              installRuntimeDependencies = true;
            };

            yaml = {
              enable = true;
              installDependencies = true;
              installRuntimeDependencies = true;
            };

            svelte = {
              enable = true;
              installDependencies = true;
              installRuntimeDependencies = true;
            };

            astro = {
              enable = true;
              installDependencies = true;
              installRuntimeDependencies = true;
            };

            tailwind = {
              enable = true;
              installDependencies = true;
              installRuntimeDependencies = true;
            };

            typescript = {
              enable = true;
              installDependencies = false;
              tsc = {
                enable = true;
              };
              oxc = {
                enable = true;
                installDependencies = true;
                installRuntimeDependencies = true;
              };
            };

            markdown = {
              enable = true;
              installDependencies = true;
              installRuntimeDependencies = true;
            };
          };

          test.core.enable = true;

          util = {
            mini-hipatterns.enable = true;
            dot.enable = true;
          };

        };

        extraPackages = with pkgs; [
          nixd
          nixfmt
          statix

          astro-language-server
          svelte-language-server
          lua-language-server
          stylua
        ];

        # See https://github.com/pfassina/lazyvim-nix/blob/main/data/treesitter.json
        treesitterParsers = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
          json
          toml
          lua
          nix
          hyprlang
        ];

        configFiles = ../../../config/lazyvim;
      };

      home.packages = [
        (pkgs.writeShellScriptBin "lazyvim" ''
          exec env NVIM_APPNAME=lazyvim nvim "$@"
          # exec env NVIM_APPNAME=lazyvim ${pkgs.neovim-unwrapped}/bin/nvim "$@"
        '')

        # (lib.mkOverride 50 (
        #   pkgs.writeShellScriptBin "nvim" ''
        #     exec env NVIM_APPNAME=lazyvim ${config.programs.neovim.finalPackage}/bin/nvim "$@"
        #   ''
        # ))
      ];

    };
}
