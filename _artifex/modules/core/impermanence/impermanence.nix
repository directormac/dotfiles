{
  lib,
  core,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    impermanence.url = "github:nix-community/impermanence";
  };

  core.impermanence = {

    includes = [
      core.impermanence.tmpfs
    ];

    /*nixfmt:disable*/
    settings = { };

    /*nixfmt:enable*/
    nixos = {
      options.impermanence.ignorePaths = lib.mkOption {
        default = [ ];
        description = "Paths ignored by persistence diff tooling.";
        type = lib.types.listOf lib.types.str;
      };

      config = {
        environment.persistence = {
          "/cache" = {
            directories = [
              "/var/lib/nixos"
              "/var/tmp"
              "/srv"
            ];

            enable = true;
            hideMounts = true;
            persistentStoragePath = "/cache";
          };

          "/persist" = {
            directories = [ ];
            enable = true;

            files = [
              "/etc/machine-id"
              "/etc/zfs/zpool.cache"
              "/etc/adjtime"
              "/root/.bash_history"
              # Host key for systemd LoadCredentialEncrypted. Must persist so
              # blobs encrypted against it (e.g. libvirt's secrets-encryption-key
              # under the persisted /var/lib/libvirt) stay decryptable across boots.
              "/var/lib/systemd/credential.secret"
            ];

            hideMounts = true;
          };
        };

        impermanence.ignorePaths = [
          "/etc/NIXOS"
          "/etc/.clean"
          "/etc/.updated"
          "/etc/.pwd.lock"
          "/var/.updated"
          "/etc/subgid"
          "/etc/subuid"
          "/etc/shadow"
          "/etc/group"
          "/etc/passwd"
          "/root/.nix-channels"
          "/var/lib/systemd/linger/"
          "/etc/ssh/authorized_keys.d/"
        ];
      };

      imports = [
        /**
          This adds the `environment.persistence` option, which is an attribute set of submodules,
          where the attribute name is the path to persistent storage.
        */
        inputs.impermanence.nixosModules.impermanence
      ];
    };

    # Home Manager persistence
    homeManager = {
      home.persistence = {
        "/cache" = {
          directories = [
            "Downloads"
            ".local/share/direnv"
            ".local/share/nix"
            ".cache"
          ];
        };

        "/persist" = {
          directories = [
            "Desktop"
            "Documents"
            "Music"
            "Pictures"
            "Public"
            "Templates"
            "Videos"
            {
              directory = ".ssh";
              mode = "0700";
            }
            {
              directory = ".local/share/keyrings";
              mode = "0700";
            }
          ];
        };
      };
    };
  };
}
