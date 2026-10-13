{ inputs, self, ... }: {

  # flake.overlays.default = final: prev: {
  # };

  flake.homeModules.devtools =
    { pkgs, config, ... }:
    let
      viteplus = inputs.nix-vite-plus.packages.${pkgs.stdenv.hostPlatform.system}.vp;
    in
    {
      imports = [
        inputs.direnv-instant.homeModules.direnv-instant
      ];

      xdg = {
        configFile = {

          "direnv/direnv.toml".source =
            config.lib.file.mkOutOfStoreSymlink "${config.preferences.dotsConfigPath}/direnv/direnv.toml";

          "mise/.miserc.toml".source =
            config.lib.file.mkOutOfStoreSymlink "${config.preferences.dotsConfigPath}/mise/.miserc.toml";

          "mise/config.toml".source =
            config.lib.file.mkOutOfStoreSymlink "${config.preferences.dotsConfigPath}/mise/config.toml";
        };
      };

      programs = {
        direnv = {
          enable = true;
          # mise.enable = true;
          nix-direnv.enable = true;
        };

        direnv-instant = {
          enable = true;
          # Defaults are fine. Tweak if desired:
          settings = {
            mux_delay = 2; # seconds before opening a tmux pane
            use_cache = true; # apply cached env instantly on prompt
            debug_log = "/tmp/direnv-instant.log";
          };
        };

        mise = {
          enable = true;
          enableZshIntegration = true;
          enableBashIntegration = true;

          # globalConfig =
          #   # toml
          #   "";
          mutableSettings = true;
        };

      };

      home.packages =
        with pkgs;
        [

          nodejs_26
          # nodejs-slim_26

          viteplus
          go
          bun
          cargo
          rustc
          deno
          mise
          pitchfork
          luarocks-nix
        ]
        ++ (with pkgs.beam29Packages; [
          hex
          elixir_1_20
        ]);

    };

  flake.nixosModules.devtools = { pkgs, config, ... }: {

    home-manager.users.${config.preferences.user.name} = {
      imports = with self.homeModules; [
        devtools
      ];

    };

    nixpkgs.overlays = [ inputs.mise-nix.overlays.default ];

    environment.systemPackages = with pkgs; [
      rage
      sops
      devenv
      secretspec
    ];

  };
}
