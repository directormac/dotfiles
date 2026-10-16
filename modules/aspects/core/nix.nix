# Core Nix Daemon, Caches, GC & AutoUpgrade Aspect
_:
{
  den.aspects.core.nix = {
    nixos =
      { config, lib, ... }:
      {
        nix = {
          settings = {
            accept-flake-config = true;

            access-tokens = lib.mkIf (config ? age && config.age.secrets ? github_api_key) [
              "!include ${config.age.secrets.github_api_key.path}"
            ];

            auto-optimise-store = true;

            experimental-features = [
              "nix-command"
              "flakes"
            ];

            keep-derivations = true;

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

            trusted-users = [
              "root"
              "@wheel"
              "artifex"
            ];

            use-xdg-base-directories = true;
          };

          gc = {
            options = "--delete-older-than 10d";
            automatic = true;
            dates = "00:01";
          };

          optimise = {
            automatic = true;
            dates = [ "05:00" ];
          };
        };

        system.autoUpgrade = {
          dates = "02:00";
          enable = lib.mkDefault true;

          flags = [
            "update"
            "nixpkgs"
          ];

          randomizedDelaySec = "45min";
        };
      };
  };
}
