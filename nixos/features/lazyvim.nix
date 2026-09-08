{ self, inputs, ... }: {
  flake.nixosModules.lazyvim = { pkgs, config, lib, ... }: {
    options.preferences.lazyvim = {
      enable = lib.mkEnableOption "LazyVim configuration";
    };

    config = lib.mkIf config.preferences.lazyvim.enable {
      home-manager.users.${config.preferences.user.name} = {
        imports = [ inputs.lazyvim.homeManagerModules.default ];

        # 2. Configure lazyvim-nix
        programs.lazyvim = {
          enable = true;
          appName = "lvim";

          extras = {
            lang = {
              nix.enable = true;
              elixir.enable = true;
              svelte.enable = true;

              json.enable = true;
              toml.enable = true;
              markdown.enable = true;

              typescript = {
                vtsls.enable = true;
                oxc.enable = true;
              };
            };
          };

          extraPackages = with pkgs; [
            taplo
            marksman
            markdownlint-cli2

            svelte-language-server
            svelte-check

            elixir-ls
            beam29Packages.expert

            typescript
            oxlint
            tsgolint
            oxfmt

            nil
            nixd
          ];

          treesitterParsers = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
            elixir
            json
            toml
            lua
            nix
            svelte
            typescript
          ];

          # 3. Point to your config/lvim directory using a relative Nix path literal.
          configFiles = ../../config/lvim;
        };

        # 4. Create the global `lvim` binary
        home.packages = [
          (pkgs.writeShellScriptBin "lvim" ''
            exec env NVIM_APPNAME=lvim nvim "$@"
          '')
        ];
      };
    };
  };
}
