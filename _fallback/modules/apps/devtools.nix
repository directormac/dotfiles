{ inputs, self, ... }: {

  # flake.overlays.default = final: prev: {
  # };

  flake.homeModules.devtools = { pkgs, config, ... }: {

  };

  flake.nixosModules.devtools = { pkgs, config, ... }: {

    home-manager.users.${config.preferences.user.name} = {
      imports = with self.homeModules; [
        devtools
      ];

      home.packages = with pkgs; [
        nodejs_26
        # nodejs-slim_26
        bun
        cargo
        deno
        mise
        pitchfork
      ];

    };

    nixpkgs.overlays = [ inputs.mise-nix.overlays.default ];

    environment.systemPackages = with pkgs; [
      rage
      sops

      direnv

      devenv
      secretspec
    ];

  };
}
