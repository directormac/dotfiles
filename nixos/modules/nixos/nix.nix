{
  flake.nixosModules.base = { config, ... }: {

    nix = {
      settings = {

        access-tokens = [ "!include ${config.age.secrets.github_api_key.path}" ];

        experimental-features = [
          "nix-command"
          "flakes"
        ];

        trusted-users = [
          "root"
          "@wheel"
          config.preferences.user.name
        ];

        # Primary system binary caches (combines NixOS defaults with nix-community)
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://cachix.cachix.org"
          "https://cache.numtide.com"
        ];

        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        ];

        # extra-substituters = [ ];
        # extra-trusted-public-keys = [
        # ];

        use-xdg-base-directories = true;
        keep-derivations = true;
        auto-optimise-store = true;
        accept-flake-config = true;
      };

      # nixPath = ["nixpkgs=${inputs.nixpkgs}"];

      optimise = {
        automatic = true;
        dates = [ "05:00" ];
      };

      gc = {
        automatic = true;
        # dates = "daily";
        dates = "00:01";
        options = "--delete-older-than 10d";
      };
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    system.autoUpgrade = {
      enable = true;
      dates = "02:00";
      flags = [
        "update"
        "nixpkgs"
      ];
      randomizedDelaySec = "45min";
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).

    system.stateVersion = "26.11"; # Did you read the comment?

  };
}
