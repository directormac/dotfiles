{ inputs, self, ... }: {

  # flake.overlays.default = final: prev: {
  # };

  flake.homeModules.devtools =
    { pkgs, config, ... }:
    let
      viteplus = inputs.nix-vite-plus.packages.${pkgs.stdenv.hostPlatform.system}.vp;
    in
    {
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
          enableZshIntegration = true;
          enableBashIntegration = true;
          mise.enable = true;
          nix-direnv.enable = true;
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

      home.packages = with pkgs; [

        nodejs_26
        # nodejs-slim_26

        viteplus
        bun
        cargo
        deno
        mise
        pitchfork
      ];

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
