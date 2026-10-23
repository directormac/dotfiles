# LazyVim Editor Aspect
{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    lazyvim = {
      url = "github:pfassina/lazyvim-nix";
    };
  };

  den.aspects.applications.dev.editor.lazyvim = {
    nixos =
      _:
      {
        nixpkgs.overlays = [
          (_final: prev: {
            vimPlugins = prev.vimPlugins.extend (
              _finalVim: prevVim: {
                codeium-nvim = prevVim.windsurf-nvim or prevVim.codeium-nvim;
              }
            );
          })
        ];
      };

    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        home.packages = lib.optional (inputs ? lazyvim) (
          pkgs.writeShellApplication {
            name = "lazyvim";

            runtimeInputs = [
              pkgs.neovim-unwrapped
              pkgs.git
            ]
            ++ (config.programs.lazyvim.extraPackages or [ ]);

            text = ''
              unset VIMINIT
              exec env NVIM_APPNAME=lazyvim nvim "$@"
            '';
          }
        );

        imports = lib.optional (
          inputs ? lazyvim && inputs.lazyvim ? homeManagerModules
        ) inputs.lazyvim.homeManagerModules.default;

        programs.lazyvim = lib.mkIf (inputs ? lazyvim && inputs.lazyvim ? homeManagerModules) {
          enable = true;
          appName = "lazyvim";
          configFiles = ../../../../../config/lazyvim;

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

          extras = {
            ai.codeium.enable = true;

            coding = {
              luasnip.enable = true;
              mini-comment.enable = true;
              mini-surround.enable = true;
              yanky.enable = true;
            };

            dap.core.enable = true;

            editor = {
              harpoon2.enable = true;
              snacks-explorer.enable = true;
              snacks-picker.enable = true;
            };

            lang = {
              astro = {
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

              json = {
                enable = true;
                installDependencies = true;
                installRuntimeDependencies = true;
              };

              markdown = {
                enable = true;
                installDependencies = true;
                installRuntimeDependencies = true;
              };

              nix = {
                enable = true;
                installDependencies = true;
                installRuntimeDependencies = true;
              };

              rust = {
                enable = true;
                installDependencies = true;
                installRuntimeDependencies = true;
              };

              sql = {
                enable = true;
                installDependencies = true;
                installRuntimeDependencies = true;
              };

              svelte = {
                enable = true;
                installDependencies = true;
                installRuntimeDependencies = true;
              };

              tailwind = {
                enable = true;
                installDependencies = true;
                installRuntimeDependencies = true;
              };

              toml = {
                enable = true;
                installDependencies = true;
                installRuntimeDependencies = true;
              };

              typescript = {
                enable = true;
                installDependencies = false;

                oxc = {
                  enable = true;
                  installDependencies = true;
                  installRuntimeDependencies = true;
                };

                tsc.enable = true;
              };

              yaml = {
                enable = true;
                installDependencies = true;
                installRuntimeDependencies = true;
              };
            };

            test.core.enable = true;
            ui.edgy.enable = true;

            util = {
              dot.enable = true;
              mini-hipatterns.enable = true;
            };
          };

          ignoreBuildNotifications = true;
          pluginSource = "nixpkgs";

          treesitterParsers = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
            fish
            hyprlang
          ];
        };

        # Disable home-manager's built-in neovim management triggered by lazyvim-nix,
        # so it does not generate ~/.config/nvim/init.lua or bin/nvim which conflicts
        # with our custom wrapper and ~/.config/nvim symlink.
        programs.neovim.enable = lib.mkForce false;
        # Pre-seed lazy.nvim into the appName's data directory so it doesn't need to be cloned
        xdg.dataFile."lazyvim/lazy/lazy.nvim".source = pkgs.vimPlugins.lazy-nvim;

        xdg.desktopEntries = lib.mkIf (inputs ? lazyvim) {
          lazyvim = {
            categories = [
              "Utility"
              "TextEditor"
              "Development"
            ];

            comment = "LazyVim text editor";
            exec = "ghostty --class=com.lazyvim.editor -e lazyvim %F";
            genericName = "Text Editor";
            icon = "nvim";

            mimeType = [
              "text/plain"
            ];

            name = "LazyVim";
            terminal = false;
            type = "Application";
          };
        };
      };

    persistHome.directories = [
      ".local/share/lazyvim"
      ".local/state/lazyvim"
    ];
  };
}
