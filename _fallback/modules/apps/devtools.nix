{ inputs, self, ... }: {

  flake.homeModules.devtools = { pkgs, config, ... }: {

    home.packages = with pkgs; [

      # nodejs_26
      nodejs-slim_26
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

      direnv

      devenv
      secretspec
    ];

  };
}
