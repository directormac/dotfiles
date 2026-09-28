{ inputs, ... }: {
  flake.homeModules.lazyvim =
    {
      pkgs,
      ...
    }:
    {
      imports = [ inputs.lazyvim.homeManagerModules.default ];

      # See  https://github.com/pfassina/lazyvim-nix/wiki/Troubleshooting
      programs.lazyvim = {
        enable = true;
        appName = "lazyvim";

        # package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;

        # See https://github.com/pfassina/lazyvim-nix/wiki/Plugin-Sourcing-Strategy#plugin-sourcing-strategy
        pluginSource = "nixpkgs";
        ignoreBuildNotifications = true; # Suppress build-time warnings

        # See https://github.com/pfassina/lazyvim-nix/blob/main/data/extras.json
        extras = {
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
        '')
      ];

    };
}
