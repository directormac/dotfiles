{ inputs, pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    hyprpicker
    swayidle 
    swaylock 
    grim
    slurp
    wl-clipboard
    cliphist
    swaynotificationcenter
  ];

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";

    NIXOS_OZON_WL = "1";
  };


  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
        user = "greeter";
      };
    };
  };

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Programs configuration
  programs.dconf.enable = true;
  programs.ssh.startAgent = true;

  # Services configuration
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.gnome.gnome-keyring.enable = true;

  # Security configurations
  security.rtkit.enable = true;
  security.polkit.enable = true;
  security.pam.services.swaylock = {};
  security.pam.loginLimits = [
    { domain = "@users"; item = "rtprio"; type = "-"; value = 1; }
  ];

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    xwayland.enable = true;
  };

  programs.waybar.enable = true;

}
