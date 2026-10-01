# ═══════════════════════════════════════════════════════════════════════════
# agenix-rekey secrets — two-layer encryption (HM + NixOS)
# ═══════════════════════════════════════════════════════════════════════════
# SOURCES  ../../../.secrets/*.age      encrypted to the MASTER pubkey only.
#          Made with `agenix edit [-i file] <source>`. Safe to commit/push
#          (master.age itself is gitignored → nobody else can read them).
# REKEYED  ../../.secrets/rekeyed/<node>/<hmac>-<name>.age
#          From `agenix rekey -a`: source re-encrypted to the node's own key.
#          HM node (artifex): hosts/artifex.pub  ↔ runtime ~/.config/agenix/key.txt
#          NixOS node (nixos): hosts/fallback_nixos.pub ↔ /etc/ssh/ssh_host_ed25519_key
#          MUST be committed — storageMode "local" means the build reads them
#          from the git tree. Content-hashed names; stale ones auto-cleaned.
#
# ADDING A NEW SECRET (cwd = _fallback, inside `nix develop`):
#   1. agenix edit ../.secrets/my_thing.age      # new: no prompt; existing: passphrase
#   2. git add ../.secrets/my_thing.age          # untracked ⇒ invisible to the flake
#   3. add the entry in `age.secrets` below:
#        my_thing = {
#          rekeyFile = ../../../.secrets/my_thing.age;
#          path = "${config.home.homeDirectory}/...";   # optional
#          mode = "0600";                               # optional
#        };
#      env-var secrets: also export it in `home.sessionVariablesExtra`.
#   4. agenix rekey -a                # passphrase prompt, writes + git-adds outputs
#   5. nixos-rebuild switch --flake . # a failed build reminds you to rekey
#   6. git add -A && git commit       # sources + rekeyed outputs + this file
#
# OPTION CHEAT-SHEET
#   rekeyFile = <src>  use this; agenix derives `file` from it automatically
#   file       = ...   DON'T set by hand — rekey ignores file-only secrets and
#                      they can't decrypt at runtime. Manual `file` is only for
#                      hand-encrypted-to-one-host files or intermediary=true.
#   path/mode          where the decrypted file appears; secrets are symlinks
#                      into /run (symlinks stat as 777 — target is 600; use
#                      `symlink = false` if a tool wants a real file)
#   intermediary = true  repository-only, never provisioned to a host
#   generator           auto-generated content via `agenix generate`
#
# GOTCHA: masterIdentities.pubkey must be the INLINE string (as below).
#   A path value is readFile'd WITH its trailing newline and rage then
#   rejects it: "Invalid recipient 'age1...\n'".
# ═══════════════════════════════════════════════════════════════════════════
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
      inputs.agenix-rekey.packages.${pkgs.stdenv.hostPlatform.system}.default
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
        # private_ssh_key = {
        #   file = ../../../.secrets/mac_mkra_dev.age;
        #   path = "${config.home.homeDirectory}/.ssh/mac_mkra_dev";
        #   mode = "0600";
        # };
        #
        # github_api_key.file = ../../../.secrets/github_api_key.age;
        private_ssh_key = {
          rekeyFile = ../../../.secrets/mac_mkra_dev.age;
          path = "${config.home.homeDirectory}/.ssh/mac_mkra_dev";
          mode = "0600";
        };
        github_api_key.rekeyFile = ../../../.secrets/github_api_key.age;
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

    age.secrets."fileserver-smb-secrets" = {
      rekeyFile = ../../../.secrets/fileserver-smb-secrets.age;
      mode = "0600"; # → /run/agenix/fileserver-smb-secrets (agenix default)
    };

    age.secrets.github_api_key.rekeyFile = ../../../.secrets/github_api_key.age;

    home-manager.users.${config.preferences.user.name}.imports = [ self.homeModules.agenix ];
  };

}
