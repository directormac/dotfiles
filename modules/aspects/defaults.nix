{
  config,
  # deadnix: skip # enable <den/brackets> syntax for demo.
  __findFile ? __findFile,
  den,
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
    nixos.system.stateVersion = "26.11";
    nixos.nix.settings.experimental-features = ["nix-command" "flakes"];
    homeManager.home.stateVersion = "26.11";
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
