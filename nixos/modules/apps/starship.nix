{ inputs, self, ... }: {

  flake.nixosModules.starship = { config, ... }: {

    home-manager.users.${config.preferences.user.name} = { config, ... }: {
      imports = [ ];
      xdg.configFile."starship.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.preferences.dotsConfigPath}/starship/starship.toml";
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      interactiveOnly = true;
    };

  };

  perSystem = { pkgs, ... }: {
    packages = {
      starship = inputs.wrappers.lib.wrapPackage (_: {
        inherit pkgs;
        package = pkgs.starship;
      });
    };

  };
}
