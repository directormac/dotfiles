{ inputs, self, ... }:
{
  flake.homeModules.noctalia =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      flakePath = "${config.home.homeDirectory}/.dotfiles";
    in
    {

      # home.file.".config/noctalia" = {
      #   source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/noctalia";
      #   recursive = true;
      # };

      programs.noctalia = {
        enable = true;

        settings = {

          sysmon = {
            enabled = true;
          };

          notification = {
            enabled = true;
            position = "top-right";
          };

        };
      };
    };

  flake.nixosModules.noctalia =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        inputs.noctalia.nixosModules.default
      ];

      home-manager.users.${config.preferences.user.name} = {
        imports = [
          self.homeModules.noctalia
        ];
      };
    };
}
