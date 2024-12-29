{ config, lib, pkgs, ... }:

{

  # GPG Agent configuration
  services.gpg-agent = {
    enable = true; # This should be true to use GPG agent
    enableSshSupport = true;
    enableZshIntegration = true; # If you're using zsh
    defaultCacheTtlSsh = 36000;
    maxCacheTtlSsh = 36000;
    pinentryFlavor = "curses"; # Or "gtk2", "qt", etc. based on your needs
  };

  # GPG configuration
  programs.gpg = {
    enable = true;
    # If you want to set specific options:
    settings = {
      trust-model = "tofu+pgp";
      keyserver = "hkps://keys.openpgp.org";
    };
  };

  # If you want to use keychain as well
  programs.keychain = {
    enable = true;
    enableZshIntegration = true; # If using zsh
    keys = [ "mac_mkra_dev" ]; # Your SSH keys
    agents = [ "ssh" "gpg" ];
  };

  # Make sure these packages are available
  environment.systemPackages = with pkgs; [ gnupg pinentry keychain ];

}
