{
  lib,
  rootPath,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.den.secretsConfig = {
    masterIdentities = mkOption {
      type = types.listOf types.path;
      description = "Age master identity public key paths for agenix-rekey";
    };
  };

  config.den.secretsConfig = {
    # -------------------------------------------------------------------------
    # MASTER IDENTITY GENERATION INSTRUCTIONS
    # -------------------------------------------------------------------------
    # To generate your master identity key, open your terminal and run:
    #
    #   $ nix develop
    #   $ mkdir -p .secrets/pub
    #   $ age-keygen -o .secrets/master.age
    #   $ age-keygen -y .secrets/master.age > .secrets/pub/master.pub
    #
    # Keep the `.secrets/master.age` file completely private (do not commit it,
    # or ensure it's in your .gitignore!).
    # You can safely commit the `.secrets/pub/master.pub` file to git.
    #
    # For a backup, consider saving the contents of `.secrets/master.age`
    # into your Bitwarden vault as a secure note.
    # -------------------------------------------------------------------------
    masterIdentities = [
      (rootPath + "/.secrets/pub/master.pub")
    ];
  };
}
