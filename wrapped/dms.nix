{
  inputs,
  self,
  ...
}:
{
  flake.nixosModules.dms = { pkgs, lib, ... }: {
    imports = [
      inputs.dms.nixosModules.dank-material-shell
      # inputs.dms.homeModules.dank-material-shell
      inputs.dms-plugin-registry.nixosModules.default
    ];
    programs.dank-material-shell = {
      enable = true;

      systemd = {
        enable = true; # Systemd service for auto-start
        restartIfChanged = true; # Auto-restart dms.service when dank-material-shell changes
      };

      # Core features
      enableSystemMonitoring = true; # System monitoring widgets (dgop)
      enableVPN = true; # VPN management widget
      enableDynamicTheming = true; # Wallpaper-based theming (matugen)
      enableAudioWavelength = true; # Audio visualizer (cava)
      enableCalendarEvents = true; # Calendar integration (khal)

      plugins = {
        #   # Simply enable plugins by their ID (from the registry)
        #   # dankBatteryAlerts.enable = true;
        #   # dockerManager.enable = true;
        dankLauncherKeys.enable = true;
        dankGifSearch.enable = true;
        #
      };
    };
  };
}
