# Secrets management via agenix and agenix-rekey
{
  lib,
  core,
  inputs,
  ...
}:
let
  masterIdentities = [
    {
      identity = "/home/artifex/.dotfiles/.secrets/master.age";
      pubkey = "age17ntux2wzhdn5d8yeg2lsw8fxk5j46sr7e0z7yx5l2mv6ng5jaukq2jkyh7";
    }
  ];

  repoRoot = ../../..;
in
{
  imports = [
    (inputs.agenix-rekey.flakeModule or { })
  ];

  core.secrets = {
    # System-level secrets (NixOS)
    nixos =
      { config, pkgs, ... }:
      {
        age.identityPaths = [
          "/persist/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key"
        ];

        age.rekey = {
          inherit masterIdentities;

          hostPubkey =
            if builtins.pathExists (repoRoot + "/.secrets/hosts/${config.networking.hostName}.pub") then
              (repoRoot + "/.secrets/hosts/${config.networking.hostName}.pub")
            else
              (repoRoot + "/.secrets/hosts/nixos.pub");

          localStorageDir =
            repoRoot
            + "/.secrets/rekeyed/${
              if builtins.pathExists (repoRoot + "/.secrets/rekeyed/${config.networking.hostName}") then
                config.networking.hostName
              else
                "nixos"
            }";

          storageMode = "local";
        };

        # Host-level secrets provisioned to real hosts (skipped on testbed sandbox)
        age.secrets = lib.mkIf (config.networking.hostName != "sandbox") {
          fileserver-smb-secrets = {
            mode = "0600";
            rekeyFile = repoRoot + "/.secrets/fileserver-smb-secrets.age";
          };

          github_api_key.rekeyFile = repoRoot + "/.secrets/github_api_key.age";
        };

        environment.systemPackages = [
          (inputs.agenix-rekey.packages.${pkgs.stdenv.hostPlatform.system}.default or pkgs.age)
        ];

        imports = [
          (inputs.agenix.nixosModules.default or { })
          (inputs.agenix-rekey.nixosModules.default or { })
        ];

        services.openssh = {
          enable = lib.mkDefault true;
        };
      };

    # User-level secrets (Home Manager)
    homeManager =
      { config, pkgs, ... }:
      {
        age = {
          identityPaths = [ "${config.home.homeDirectory}/.config/agenix/key.txt" ];

          rekey = {
            inherit masterIdentities;
            hostPubkey = repoRoot + "/.secrets/hosts/artifex.pub";
            localStorageDir = repoRoot + "/.secrets/rekeyed/${config.home.username}";
            storageMode = "local";
          };

          secrets = {
            github_api_key.rekeyFile = repoRoot + "/.secrets/github_api_key.age";

            private_ssh_key = {
              mode = "0600";
              path = "${config.home.homeDirectory}/.ssh/mac_mkra_dev";
              rekeyFile = repoRoot + "/.secrets/mac_mkra_dev.age";
            };
          };
        };

        home.packages = [
          (inputs.agenix-rekey.packages.${pkgs.stdenv.hostPlatform.system}.default or pkgs.age)
        ];

        home.sessionVariablesExtra = ''
          if [ -f "${config.age.secrets.github_api_key.path}" ]; then
            export GITHUB_API_KEY="$(cat "${config.age.secrets.github_api_key.path}")"
          fi
        '';

        imports = [
          (inputs.agenix.homeManagerModules.default or { })
          (inputs.agenix-rekey.homeManagerModules.default or { })
        ];
      };

    # Persist the agenix key directory across impermanence boots
    persistHome.directories = [
      ".config/agenix"
    ];
  };

  den.aspects.artifex.includes = [
    core.secrets
  ];

  den.aspects.nixos.includes = [
    core.secrets
  ];

  # Attach core.secrets to super host, nixos host, and artifex user
  den.aspects.super.includes = [
    core.secrets
  ];
}
