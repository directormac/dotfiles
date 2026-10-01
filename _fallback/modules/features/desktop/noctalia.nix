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

      home.file.".config/noctalia" = {
        source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/config/noctalia";
        recursive = true;
      };

      programs.noctalia = {
        enable = lib.mkDefault true;
        package = lib.mkForce inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
        systemd.enable = lib.mkDefault false; # Handled via compositor autostart
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

      programs.noctalia = {
        enable = lib.mkDefault true;
        package = lib.mkForce inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
      };

      home-manager.users.${config.preferences.user.name} = {
        imports = [
          self.homeModules.noctalia
        ];
      };
    };
}
