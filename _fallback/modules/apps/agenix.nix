{
  inputs,
  self,
  ...
}:
let
  masterIdentities = [
    {
      identity = "/home/artifex/.dotfiles/.secrets/master.age"; # absolute string → never copied to the store (it's gitignored)
      pubkey = "age17ntux2wzhdn5d8yeg2lsw8fxk5j46sr7e0z7yx5l2mv6ng5jaukq2jkyh7";
      # pubkey = ../../../.secrets/master.pub; # path → auto-readFile'd at eval
    }
  ];
in
{
  flake.homeModules.agenix = { config, pkgs, ... }: {

    imports = [
      inputs.agenix.homeManagerModules.default
      inputs.agenix-rekey.homeManagerModules.default
    ];

    home.packages = [
      # inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.agenix-rekey.packages.${pkgs.system}.default
    ];

    home.sessionVariablesExtra = ''
      if [ -f "${config.age.secrets.github_api_key.path}" ]; then
        export GITHUB_API_KEY="$(cat "${config.age.secrets.github_api_key.path}")"
      fi
    '';

    age = {
      identityPaths = [ "${config.home.homeDirectory}/.config/agenix/key.txt" ];

      rekey = {
        inherit masterIdentities;
        storageMode = "local";
        localStorageDir = ../../. + "/.secrets/rekeyed/${config.home.username}";
        hostPubkey = ../../../.secrets/hosts/artifex.pub;
      };

      secrets = {
        # private_ssh_key = {
        #   file = ../../../.secrets/private_ssh_key.age;
        #   path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        #   mode = "0600";
        # };
        private_ssh_key = {
          file = ../../../.secrets/mac_mkra_dev.age;
          path = "${config.home.homeDirectory}/.ssh/mac_mkra_dev";
          mode = "0600";
        };

        github_api_key.file = ../../../.secrets/github_api_key.age;
      };
    };

  };

  flake.nixosModules.agenix = { config, ... }: {
    imports = [
      inputs.agenix.nixosModules.default
      inputs.agenix-rekey.nixosModules.default
    ];
    age.rekey = {
      inherit masterIdentities;
      storageMode = "local";
      localStorageDir = ../../. + "/.secrets/rekeyed/${config.networking.hostName}";
      hostPubkey = ../../../.secrets/hosts/fallback_nixos.pub; # your filename
    };
    home-manager.users.${config.preferences.user.name}.imports = [ self.homeModules.agenix ];
  };

}
