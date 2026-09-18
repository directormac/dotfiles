{
  config,
  # deadnix: skip # enable <den/brackets> syntax for demo.
  __findFile ? __findFile,
  den,
  inputs,
  lib,
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
    nixos = {
      lib,
      pkgs,
      config,
      ...
    }: {
      # imports = [
      #   inputs.nix-index-database.nixosModules.nix-index
      # ];

      nix = {
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];

          # Deduplicate and optimize nix store
          auto-optimise-store = true;

          accept-flake-config = true;

          # Avoid unwanted garbage collection when using nix-direnv.
          keep-outputs = true;
          keep-derivations = true;

          # Use @wheel for trusted users instead of trying to resolve user name which might be absent
          trusted-users = ["root" "@wheel"];

          use-xdg-base-directories = true;
        };
        nixPath = ["nixpkgs=${inputs.nixpkgs}"];
        optimise.automatic = false;
        gc = {
          automatic = true;
          dates = "daily";
          options = "--delete-older-than 5d";
        };
      };

      nixpkgs = {
        overlays = [
          # Add overlays your own flake exports (from overlays and pkgs dir):
          # inputs.self.overlays.additions
          # inputs.self.overlays.modifications
        ];
        # Overlays contributed by aspects via the `nixpkgsOverlays` quirk.
        # Applies to home-manager's pkgs too, since `home-manager.useGlobalPkgs = true`.
        # ++ lib.flatten nixpkgsOverlays;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
      };

      # List packages installed in system profile. To search, run:
      # $ nix search wget
      environment = {
        # defaultPackages = [ ]; # "Historical mistake". Removes pkgs.{strace,rsync,perl} from installed packages.

        systemPackages = with pkgs; [
          manix
          devenv
          git
          gnupg
          killall
          pciutils
          usbutils
          wget
          vim
        ];

        shells = with pkgs; [
          bash
          zsh
          fish
        ];
      };

      programs.zsh.enable = true;
      users.defaultUserShell = pkgs.zsh;

      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      # programs.mtr.enable = true;
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };

      services.fstrim = {
        enable = true;
        #interval = "weekly"; # The default.
      };

      # Enable the X11 windowing system.
      # You can disable this if you're only using the Wayland session.
      services.xserver.enable = true;

      # Configure keymap in X11
      # services.xserver = {
      #   xkb.layout = "cz";
      #   xkb.variant = "coder";
      # };

      # Enable CUPS to print documents.
      services.printing.enable = true;

      # Enable sound with pipewire.
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session.enable = true;
      };

      home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;
        backupFileExtension = "backup";
        overwriteBackup = true;
      };

      security.polkit.enable = true;

      system.stateVersion = "26.11";
    };

    homeManager = {
      # Nicely reload system units when changing configs
      systemd.user.startServices = "sd-switch";

      home.stateVersion = "26.11";
    };
  };

  den.schema.user.classes = lib.mkDefault [
    "homeManager"
    # "hjem"
    # "maid"
  ];

  # These are functions that produce configs
  den.default.includes = [
    # Automatically set hostname
    # <den/hostname>
    den.batteries.hostname

    # Automatically create the user on host.
    # <den/define-user>
    den.batteries.define-user

    # Provides the `flake-parts` `self'` (the flake's `self` with system pre-selected) as a top-level module argument.
    # This allows modules to access per-system flake outputs without needing
    # `pkgs.stdenv.hostPlatform.system`.
    # ## Usage
    # **Global (Recommended):**
    # Apply to all hosts, users, and homes.
    #     den.default.includes = [ den.self' ];
    # **Specific:**
    # Apply only to a specific host, user, or home aspect.
    #     den.aspects.my-laptop.includes = [ den.self' ];
    #     den.aspects.alice.includes = [ den.self' ];
    # **Note:** This aspect is contextual. When included in a `host` aspect, it
    # configures `self'` for the host's OS. When included in a `user` or `home`
    # aspect, it configures `self'` for the corresponding Home Manager configuration.
    # den.batteries.self'

    # Provides the `flake-parts` `inputs'` (the flake's `inputs` with system pre-selected)
    # as a top-level module argument.
    # This allows modules to access per-system flake outputs without needing
    # `pkgs.stdenv.hostPlatform.system`.
    # ## Usage
    # **Global (Recommended):**
    # Apply to all hosts, users, and homes.
    #     den.default.includes = [ den.inputs' ];
    # **Specific:**
    # Apply only to a specific host, user, or home aspect.
    #     den.aspects.my-laptop.includes = [ den.inputs' ];
    #     den.aspects.alice.includes = [ den.inputs' ];
    # **Note:** This aspect is contextual. When included in a `host` aspect, it
    # configures `inputs'` for the host's OS. When included in a `user` or `home`
    # aspect, it configures `inputs'` for the corresponding Home Manager configuration.
    # den.batteries.inputs'

    den.batteries.flake-scope

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
