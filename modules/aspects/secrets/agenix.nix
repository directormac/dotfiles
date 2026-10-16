# Secrets Management via Agenix & Agenix-Rekey Leaf Aspect
{
  lib,
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

  den.aspects.secrets.agenix = {
    nixos =
      {
        config,
        pkgs,
        secrets ? [ ],
        ...
      }:
      let
        collectedSecrets = lib.foldl' lib.recursiveUpdate { } secrets;
        defaultSecrets = lib.optionalAttrs (config.networking.hostName != "sandbox") {
          fileserver-smb-secrets = {
            mode = "0600";
            rekeyFile = repoRoot + "/.secrets/fileserver-smb-secrets.age";
          };

          github_api_key.rekeyFile = repoRoot + "/.secrets/github_api_key.age";
        };
      in
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

        age.secrets = defaultSecrets // collectedSecrets;

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

    homeManager =
      {
        config,
        pkgs,
        secretsHome ? [ ],
        ...
      }:
      let
        collectedSecretsHome = lib.foldl' lib.recursiveUpdate { } secretsHome;
        defaultHomeSecrets = {
          github_api_key.rekeyFile = repoRoot + "/.secrets/github_api_key.age";

          private_ssh_key = {
            mode = "0600";
            path = "${config.home.homeDirectory}/.ssh/mac_mkra_dev";
            rekeyFile = repoRoot + "/.secrets/mac_mkra_dev.age";
          };
        };
      in
      {
        age = {
          identityPaths = [ "${config.home.homeDirectory}/.config/agenix/key.txt" ];

          rekey = {
            inherit masterIdentities;
            hostPubkey = repoRoot + "/.secrets/hosts/artifex.pub";
            localStorageDir = repoRoot + "/.secrets/rekeyed/${config.home.username}";
            storageMode = "local";
          };

          secrets = defaultHomeSecrets // collectedSecretsHome;
        };

        home.packages = [
          (inputs.agenix-rekey.packages.${pkgs.stdenv.hostPlatform.system}.default or pkgs.age)
        ];

        home.sessionVariablesExtra = ''
          if [ -f "${config.age.secrets.github_api_key.path}" ]; then
            export GITHUB_API_KEY="$(cat "${config.age.secrets.github_api_key.path}")"
            export GITHUB_TOKEN="$GITHUB_API_KEY"
            export GH_TOKEN="$GITHUB_API_KEY"
            export NIX_CONFIG="extra-access-tokens = github.com=$GITHUB_API_KEY''${NIX_CONFIG:+ $NIX_CONFIG}"
            if [ ! -f "${config.home.homeDirectory}/.config/nix/nix.conf" ] || ! grep -q "extra-access-tokens" "${config.home.homeDirectory}/.config/nix/nix.conf" 2>/dev/null; then
              mkdir -p "${config.home.homeDirectory}/.config/nix"
              echo "extra-access-tokens = github.com=$GITHUB_API_KEY" > "${config.home.homeDirectory}/.config/nix/nix.conf"
              chmod 0600 "${config.home.homeDirectory}/.config/nix/nix.conf"
            fi
          fi
        '';

        imports = [
          (inputs.agenix.homeManagerModules.default or { })
          (inputs.agenix-rekey.homeManagerModules.default or { })
        ];
      };

    persistHome.directories = [
      ".config/agenix"
    ];
  };

}
