{ self, inputs, ... }: {

  flake.homeModules.yazi = { config, ... }: {
    home.file = {
      ".config/yazi".source = config.lib.file.mkOutOfStoreSymlink "/home/artifex/.dotfiles/config/yazi";
    };
  };

  flake.nixosModules.yazi = { pkgs, config, ... }: {
    # This is applied to this host with home-manager
    home-manager.users.${config.preferences.user.name} = {
      imports = [
        self.homeModules.yazi
      ];
    };

    programs.yazi = {
      enable = true;
      plugins = with pkgs.yaziPlugins; {
        inherit git;
        inherit starship;
      };
    };
  };

  perSystem = { pkgs, ... }: {
    packages.yazi = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.yazi;
    };
  };

}
