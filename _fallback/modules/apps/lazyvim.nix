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
          ui = {
            edgy.enable = true;
          };
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

            markdown = {
              enable = true;
              installDependencies = true;
              installRuntimeDependencies = true;
            };

          };
        };

        extraPackages = with pkgs; [
          nixd
          nixfmt
          statix

          lua-language-server
          stylua
        ];

        # See https://github.com/pfassina/lazyvim-nix/blob/main/data/treesitter.json
        treesitterParsers = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
          json
          toml
          lua
          nix
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
