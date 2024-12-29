{ pkgs, lib, inputs, username, ... }: {

  imports = [
    ./locale.nix

  ];

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  users.defaultUserShell = pkgs.zsh;

  nix.settings.trusted-users = [ username ];

  nix.settings = { experimental-features = [ "nix-command" "flakes" ]; };

  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;

  environment.pathsToLink = [ "/libexec" ];

  environment.shells = with pkgs; [ zsh ];

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    git
    neovim
    aria2
    # xdg-user-dirs
    # xdg-utils
    # stow
    # inputs.wezterm.packages.${pkgs.system}.default
  ];

  fonts = {

    packages = with pkgs; [

      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      material-design-icons
      font-awesome
      source-han-sans
      source-han-sans-japanese
      source-han-serif-japanese
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono

    ];

    # use fonts specified by user rather than default ones
    enableDefaultPackages = false;

    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" "Noto Color Emoji" ];
      sansSerif = [ "Noto Sans" "Noto Color Emoji" ];
      monospace = [ "JetBrainsMono Nerd Font" "Noto Color Emoji" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  programs.dconf.enable = true;

  security.polkit.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
