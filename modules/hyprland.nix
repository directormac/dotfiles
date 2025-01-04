{ inputs, pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    kitty
    hyprpicker
    hypridle
    hyprlock
    xdg-desktop-portal-hyprland
    hyprsunset
    hyprpolkitagent
    hyprcursor
    aquamarine
    hyprgraphics
    hyprland-qtutils
  ];

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";

    NIXOS_OZON_WL = "1";
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;

    # set the flake package
    package =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # make sure to also set the portal package, so that they are in sync
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

  };

}
