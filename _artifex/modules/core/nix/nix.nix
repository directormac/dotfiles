{
  core.nix = {
    os = {
      nix = {
        settings = {
          allow-import-from-derivation = true;
          auto-optimise-store = true;
          builders-use-substitutes = true;
          connect-timeout = 5;

          experimental-features = [
            "auto-allocate-uids"
            "cgroups"
            "flakes"
            "nix-command"
            "pipe-operators"
          ];

          extra-substituters = [
            # Nix community cache server.
            "https://nix-community.cachix.org"

            # Nix cache
            "https://cache.nixos.org/"
          ];

          extra-trusted-public-keys = [
            # Nix community cache server public key.
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

            # Nix cache public key
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          ];

          fallback = true;
          http-connections = 128;
          keep-derivations = true;
          keep-outputs = true;
          log-lines = 25;
          max-free = 1000000000;
          max-jobs = "auto";
          max-substitution-jobs = 128;
          min-free = 128000000;
          sandbox = "relaxed";
          use-xdg-base-directories = true;
          warn-dirty = false;
        };

        gc = {
          options = "--delete-older-than 8d";
          automatic = true;
        };
      };
    };

    nixos = { lib, ... }: {
      nix = {
        settings = {
          # allowed-users only gates who may connect to the daemon; every local
          # login user needs it (HM activation, nix-shell). It is NOT a privilege
          # boundary, so it must not track wheel — decoupled from sudo like login.
          # With mutableUsers = false, local accounts are exactly the resolved
          # registry users, so "*" is precisely the login set.
          allowed-users = [ "*" ];

          # trusted-users grants root-equivalent nix power (override settings,
          # add substituters, import untrusted store paths) — admins only.
          trusted-users = [
            "root"
            "@wheel"
          ];
        };

        daemonCPUSchedPolicy = lib.mkDefault "batch";
        daemonIOSchedClass = lib.mkDefault "idle";
        daemonIOSchedPriority = lib.mkDefault 7;
        gc.dates = "05:00";
      };

      # OOM prevention: separate slice for nix-daemon
      systemd = {
        services."nix-daemon".serviceConfig = {
          OOMScoreAdjust = lib.mkDefault 250;
          Slice = "nix-daemon.slice";
        };

        services.nix-gc.serviceConfig = {
          CPUSchedulingPolicy = "batch";
          IOSchedulingClass = "idle";
          IOSchedulingPriority = 7;
        };

        slices."nix-daemon".sliceConfig = {
          ManagedOOMMemoryPressure = "kill";
          ManagedOOMMemoryPressureLimit = "50%";
          # A pressure policy alone only reacts once the host is already
          # struggling, and it cannot act at all while the kernel still sees
          # swap to hand out. These are the standing bound: High throttles the
          # slice into reclaim, Max fails one build rather than letting the
          # builds take the machine with them. systemd resolves both against
          # physical RAM, so a build host and a small node are bounded in the
          # same proportion without either being named here.
          MemoryHigh = "60%";
          MemoryMax = "85%";
        };
      };
    };
  };
}
