{
  inputs,
  pkgs,
  ...
}: {
  flake-file.inputs.lazyvim-nix = {
    url = "github:pfassina/lazyvim-nix";
    # inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.editor.lazyvim = {
    nixos.nixpkgs.overlays = [
      (final: prev: {
        vimPlugins = prev.vimPlugins.extend (vfinal: vprev: {
          typescript-nvim = prev.vimUtils.buildVimPlugin {
            pname = "typescript-nvim";
            version = "nixpkgs-stable";
            src = prev.emptyDirectory;
          };
        });
      })
    ];

    homeManager = {
      imports = [inputs.lazyvim-nix.homeManagerModules.default];

      programs.neovim = {
        defaultEditor = true;
        viAlias = true;
      };

      programs.lazyvim = {
        enable = true;

        # See https://github.com/pfassina/lazyvim-nix/wiki/Plugin-Sourcing-Strategy#plugin-sourcing-strategy
        pluginSource = "nixpkgs";
        ignoreBuildNotifications = true; # Suppress build-time warnings

        extras = {
          # ai.copilot.enable = true;
          coding = {
            mini-surround.enable = true;
            yanky.enable = true;
          };
          editor = {
            inc-rename.enable = true;
          };
          lang = {
            nix.enable = true;
            markdown.enable = true;

            # typescript = {
            #   enable = true;
            #   installDependencies = false;
            #   tsc = {
            #     enable = true;
            #   };
            #   oxc = {
            #     enable = true;
            #     installDependencies = true;
            #     installRuntimeDependencies = true;
            #   };
            # };
          };
          util.mini-hipatterns.enable = true;
        };

        plugins = {
          colorscheme = ''
            return {
              "LazyVim/LazyVim",
              opts = {
                colorscheme = "catppuccin-nvim",
              },
            }
          '';
        };

        extraPackages = with pkgs; [
          # nixd
          # alejandra
        ];

        # See https://github.com/pfassina/lazyvim-nix/blob/main/data/treesitter.json
        treesitterParsers = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
          # toml
          # lua
          # nix
        ];
      };
    };
  };
}
