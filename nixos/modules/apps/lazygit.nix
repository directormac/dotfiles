{ self, ... }:
{
  # Declared once here; the flake-parts wrappers module turns this into
  # outputs.wrappers.lazygit and packages.<system>.lazygit (in-store config).
  flake.wrappers.lazygit =
    {
      config,
      wlib,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ wlib.modules.default ];

      options.configFile = lib.mkOption {
        type = lib.types.either lib.types.str lib.types.path;
        default = ../../../config/lazygit/config.yml;
        description = "Lazygit config file. Defaults to the in-store copy; hosts override it with the live checkout.";
      };

      config.package = pkgs.lazygit;
      config.flags."--use-config-file" = "${config.configFile}";
    };

  flake.nixosModules.lazygit =
    { config, ... }:
    {
      imports = [ self.wrappers.lazygit.install ];

      wrappers.lazygit = {
        enable = true;
        configFile = "${config.preferences.dotsConfigPath}/lazygit/config.yml";
      };
    };
}
