# Core Nix Daemon, Caches, GC & AutoUpgrade Aspect
{
  den.aspects.core.nix = {
    nixos =
      { config, lib, ... }:
      {
        nix = {
          settings = {
            accept-flake-config = true;
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

          extraOptions = lib.mkIf (config ? age && config.age.secrets ? github_api_key) ''
            !include /run/nix-access-tokens.conf
          '';

          gc = {
            automatic = false;
          };

          optimise = {
            automatic = true;
            dates = [ "05:00" ];
          };
        };

        programs.nh = {
          enable = lib.mkDefault true;

          clean = {
            enable = lib.mkDefault true;
            extraArgs = lib.mkDefault "--keep-since 4d --keep 3";
          };

          flake =
            let
              primaryUser = lib.findFirst (u: u.isNormalUser) null (builtins.attrValues config.users.users);
            in
            lib.mkDefault (
              if primaryUser != null then "${primaryUser.home}/.dotfiles" else "/home/artifex/.dotfiles"
            );
        };

        system.activationScripts.nixAccessTokens =
          lib.mkIf (config ? age && config.age.secrets ? github_api_key)
            (
              lib.stringAfter [ "agenixInstall" ] ''
                if [ -f "${config.age.secrets.github_api_key.path}" ]; then
                  echo "extra-access-tokens = github.com=$(cat "${config.age.secrets.github_api_key.path}")" > /run/nix-access-tokens.conf
                  chmod 0444 /run/nix-access-tokens.conf
                fi
              ''
            );

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
