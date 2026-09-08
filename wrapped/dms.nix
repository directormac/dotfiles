{
  inputs,
  self,
  ...
}:
{
  flake.nixosModules.dms = { pkgs, lib, ... }: {
    imports = [
      inputs.dms.nixosModules.dank-material-shell
    ];
    programs.dank-material-shell = {
      enable = true;

      # plugins = {
      #   # Simply enable plugins by their ID (from the registry)
      #   # dankBatteryAlerts.enable = true;
      #   # dockerManager.enable = true;
      #   dankLauncherKeys.enbale = true;
      #   dankGifSearch.enable = true;
      #
      # };
    };
  };
}
