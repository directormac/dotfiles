{
  config,
  # deadnix: skip # enable <den/brackets> syntax for demo.
  __findFile ? __findFile,
  den,
  inputs,
  ...
}: {
  den.schema.aspect = {lib, ...}: {
    options.repoConfigDir = lib.mkOption {
      type = lib.types.path;
      description = "Global variable pointing to the repository config directory";
    };
    config.repoConfigDir = ../../config;
  };

  # Lets also configure some defaults using aspects.
  # These are global static settings.
  den.default = {
    homeManager.home.stateVersion = "26.11";

    nixos = {
      pkgs,
      config,
      ...
    }: {
      system.stateVersion = "26.11";

      imports = [
        inputs.nix-index-database.nixosModules.nix-index
      ];

      programs = {
        nix-index-database.comma.enable = true;
        nix-ld.enable = true;
      };

      nix = {
        settings = {
          # Use @wheel for trusted users instead of trying to resolve user name which might be absent
          trusted-users = ["root" "@wheel"];
          use-xdg-base-directories = true;
          keep-derivations = true;
          auto-optimise-store = true;
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          accept-flake-config = true;
        };
        nixPath = ["nixpkgs=${inputs.nixpkgs}"];
        optimise.automatic = false;
        gc = {
          automatic = true;
          dates = "daily";
          options = "--delete-older-than 5d";
        };
      };

      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [
        nil
        nixd
        statix
        alejandra
        nixfmt-rfc-style
        manix
        nix-inspect
        devenv
      ];
    };
  };

  # These are functions that produce configs
  den.default.includes = [
    # Automatically set hostname
    <den/hostname>

    # Automatically create the user on host.
    <den/define-user>

    # Configure home-manager defaults (useUserPackages, useGlobalPkgs, etc)
    {
      os = {
        home-manager = {
          useUserPackages = true;
          useGlobalPkgs = true;
          backupFileExtension = "backup";
          overwriteBackup = true;
        };
      };
    }

    # Disable booting when running on CI on all NixOS hosts.
    (
      if config ? _module.args.CI
      then <runner/ci-no-boot>
      else {}
    )

    # NOTE: be cautious when adding fully parametric functions to defaults.
    # defaults are included on EVERY host/user/home, and IF you are not careful
    # you could be duplicating config values. For example:
    #
    #  # This will append 42 into foo option for the {host} and for EVERY {host,user}
    #     ({ host, ... }: { nixos.foo = [ 42 ]; }) # DO-NOT-DO-THIS.
    #
    #  # A plain function destructuring { host } binds host once at the host
    #  # scope (nixos-class content emits there):
    #     ({ host, ... }: { nixos.foo = [ 42 ]; })
    #  # Destructuring { host, user } fans out over the host's users and emits
    #  # on the host (one nixos contribution per user); the bound user is the
    #  # arg source, not the output target. At user scope both args are in-ctx
    #  # and it binds once:
    #     ({ host, user, ... }: { nixos.foo = [ 42 ]; })
    #  # Destructuring { home } binds home at standalone-home scope:
    #     ({ home, ... }: { homeManager.foo = [ 42 ]; })
  ];
}
