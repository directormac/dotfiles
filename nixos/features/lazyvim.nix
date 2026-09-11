{inputs, ...}: {
  flake.nixosModules.lazyvim = {
    pkgs,
    config,
    lib,
    ...
  }: {
    options.preferences.lazyvim = {
      enable = lib.mkEnableOption "LazyVim configuration";
    };

    config = lib.mkIf config.preferences.lazyvim.enable {
      home-manager.users.${config.preferences.user.name} = {
        imports = [inputs.lazyvim.homeManagerModules.default];

        # See  https://github.com/pfassina/lazyvim-nix/wiki/Troubleshooting
        programs.lazyvim = {
          enable = true;
          appName = "lvim";

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

              elixir = {
                enable = true;
                installDependencies = true;
                installRuntimeDependencies = true;
              };

              svelte = {
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
            };
          };

          extraPackages = with pkgs; [
            svelte-language-server
            svelte-check
            typescript

            nixd
            nixfmt
          ];

          # See https://github.com/pfassina/lazyvim-nix/blob/main/data/treesitter.json
          treesitterParsers = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
            elixir
            json
            toml
            lua
            nix
            svelte
            typescript
          ];

          configFiles = ../../config/lvim;
        };

        home.packages = [
          (pkgs.writeShellScriptBin "lvim" ''
            exec env NVIM_APPNAME=lvim nvim "$@"
          '')
        ];
      };
    };
  };
}
