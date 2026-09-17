{
  runner.hyprland-wm.nixos = {
    lib,
    pkgs,
    ...
  }: {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    environment.systemPackages = with pkgs; [
      kitty
    ];

    # services.xserver.enable = true;
    # services.desktopManager.plasma6.enable = true;
    services.displayManager.sddm.enable = true;

    services.displayManager = {
      # defaultSession = lib.mkDefault "plasma";
      enable = true;
    };
  };
}
