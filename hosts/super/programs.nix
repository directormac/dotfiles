{ config, pkgs, ... }:

{
  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
}
