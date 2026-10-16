# LazyVim Editor Aspect
_:
{
  flake-file.inputs = {
    lazyvim = {
      url = "github:pfassina/lazyvim-nix";
    };
  };

  den.aspects.applications.dev.editor.lazyvim = {
    # Disabled for now
    /*
      nixos =
        { ... }:
        {
          nixpkgs.overlays = [
            (final: prev: {
              vimPlugins = prev.vimPlugins.extend (
                finalVim: prevVim: {
                  codeium-nvim = prevVim.windsurf-nvim or prevVim.codeium-nvim;
                }
              );
            })
          ];
        };

      homeManager =
        {
          pkgs,
          lib,
          ...
        }:
        {
          imports = lib.optional (
            inputs ? lazyvim && inputs.lazyvim ? homeManagerModules
          ) inputs.lazyvim.homeManagerModules.default;

          programs.lazyvim = lib.mkIf (inputs ? lazyvim && inputs.lazyvim ? homeManagerModules) {
            enable = true;
            appName = "lazyvim";
            pluginSource = "nixpkgs";
            ignoreBuildNotifications = true;

            extras = {
              ai.codeium.enable = true;
              ui.edgy.enable = true;
              editor = {
                harpoon2.enable = true;
                snacks-explorer.enable = true;
                snacks-picker.enable = true;
              };
              dap.core.enable = true;
              coding = {
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
                  tsc.enable = true;
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
              shellcheck
              bash-language-server
              astro-language-server
              svelte-language-server
              lua-language-server
              stylua
            ];

            treesitterParsers = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
              fish
              hyprlang
            ];

            configFiles = ../../../../../config/lazyvim;
          };

          home.packages = lib.optional (inputs ? lazyvim) (
            pkgs.writeShellScriptBin "lazyvim" ''
              exec env NVIM_APPNAME=lazyvim nvim "$@"
            ''
          );
        };
    */
  };
}
