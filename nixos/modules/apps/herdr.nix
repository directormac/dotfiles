{
  inputs,
  self,
  ...
}:

{
  flake.homeModules.herdr =
    { pkgs, config, ... }:
    let
      herdr = inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      programs.herdr = {
        enable = true;
        # package = inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default;
        package = herdr;
      };

      home.file.".config/herdr/config.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.preferences.dotsConfigPath}/herdr/config.toml";

      systemd.user.services.herdr-server = {
        Unit = {
          Description = "Herdr Server";
          Documentation = "herdr --help";
          After = [ "graphical-session.target" ];
        };
        Service = {
          Type = "forking";
          ExecStart = "${herdr} server";
          KillMode = "mixed";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

    };
  flake.nixosModules.herdr =
    { pkgs, config, ... }:
    {

      home-manager.users.${config.preferences.user.name} = {
        imports = [
          self.homeModules.herdr
        ];
      };

    };

  perSystem =
    { pkgs, ... }:
    {

    };
}
