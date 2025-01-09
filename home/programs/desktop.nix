{ pkgs, ... }: {

  # imports =
  #   [ ./helix ];

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Audio
  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Programs configuration
  programs.dconf.enable = true;

  services.gnome.gnome-keyring.enable = true;

  # Security configurations
  security.rtkit.enable = true;
  security.polkit.enable = true;
  security.pam.services.swaylock = {};
  security.pam.loginLimits = [
    { domain = "@users"; item = "rtprio"; type = "-"; value = 1; }
  ];

  home.packages = with pkgs; [
    firefox 
  ];
}
