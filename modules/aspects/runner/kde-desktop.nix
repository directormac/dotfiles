{
  runner.kde-desktop.nixos = {
    lib,
    pkgs,
    ...
  }: {
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    services.displayManager = {
      defaultSession = lib.mkDefault "plasma";
      enable = true;
    };
  };
}
