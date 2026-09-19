{inputs, ...}: {
  # Note: `devenv` is already pulled in via your `tooling.nix` so we don't need to add it here.

  flake-file = {
    nixConfig = {
      extra-substituters = [
        "https://devenv.cachix.org"
      ];
      extra-trusted-public-keys = [
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
    };

    inputs = {
      # devenv needs the project directory. Without this it falls back to `builtins.getEnv "PWD"`, which is empty under pure
      #  evaluation.
      # /dev/null` keeps the declaration host-independent (since `.devenv/root` is gitignored); `.envrc` overrides it
      #  per-checkout.
      devenv-root = {
        url = "file+file:///dev/null";
        flake = false;
      };

      devenv.url = "github:cachix/devenv";

      nix2container = {
        url = "github:nlewo/nix2container";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      make-shell.url = "github:nicknovitski/make-shell";

      mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    };
  };

  imports = [
    inputs.devenv.flakeModule
    # inputs.make-shell.flakeModules.default
  ];

  perSystem = {
    config,
    pkgs,
    lib,
    ...
  }: {
    # Per-system attributes can be defined here. The self' and inputs'
    # module parameters provide easy access to attributes of the same
    # system.
    # https://devenv.sh/reference/options/
    devenv.shells.default = {
      # devenv.root = let
      #   flakeRoot = builtins.toString inputs.self;
      # in
      #   flakeRoot;

      languages = {
        nix.enable = true;
        lua.enable = true;
      };

      # https://devenv.sh/packages/
      packages =
        [
          pkgs.age
          pkgs.just

          pkgs.git
          pkgs.gh
          pkgs.nix # Always use the nix version from this flake's nixpkgs version
          pkgs.nixos-rebuild # Ensure nixos-rebuild is available for darwin systems
          pkgs.nix-output-monitor
          pkgs.nix-fast-build
          pkgs.nix-search-tv
          pkgs.nil
          pkgs.fzf
          pkgs.nixd
          pkgs.sops
          # config.packages.gen-lsp-mcp # Uncomment when this package exists in your flake
        ]
        ++ lib.optionals pkgs.stdenv.buildPlatform.isDarwin [
          pkgs.coreutils-full # Include GNU coreutils for darwin systems
        ];

      # https://devenv.sh/basics/
      # enterShell = ''
      #   hello         # Run scripts directly
      #   git --version # Use packages
      # '';

      # https://devenv.sh/tests/
      # enterTest = ''
      #   echo "Running tests"
      #   git --version | grep --color=auto "${pkgs.git.version}"
      # '';

      # https://devenv.sh/git-hooks/
      # git-hooks.hooks.shellcheck.enable = true;

      # https://devenv.sh/scripts/
      scripts = {
        # --- GUIDE: How to create custom scripts in devenv ---
        #
        # Option 1 (Simple Inline Script):
        # If your script is just a few lines of bash, you can write it directly in `exec`.
        # Any package you add to `devenv.shells.default.packages` will be available in the PATH.
        # example-script = {
        #   exec = ''
        #     echo "Hello World"
        #     rg "something" # Assuming pkgs.ripgrep is in your packages list
        #   '';
        #   description = "An example inline script";
        # };
        #
        # Option 2 (Wrapped Executable):
        # If you are wrapping an existing derivation or `writeShellApplication` to ensure
        # it has isolated dependencies (like `fzf`), you can evaluate it and call its binary.
        # We use `lib.getExe` to get the path to the main binary of the derivation.
        ns = {
          exec = let
            # We recreate your writeShellApplication here so it has its own isolated PATH
            # containing fzf and nix-search-tv.
            nsApp = pkgs.writeShellApplication {
              name = "ns";
              runtimeInputs = with pkgs; [
                fzf
                nix-search-tv
              ];
              text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
            };
          in "${lib.getExe nsApp} \"$@\"";
          description = "Search nixpkgs interactively using nix-search-tv and fzf";
        };

        # Using built-in packages:
        nh = {
          exec = "${lib.getExe pkgs.nh} \"$@\"";
          description = "Nix helper for nixpkgs development";
        };
        treefmt = {
          exec = "${config.treefmt.build.wrapper}/bin/treefmt \"$@\"";
          description = "Format all files";
        };
        nix-tree = {
          exec = "${lib.getExe pkgs.nix-tree} \"$@\"";
          description = "Interactively browse dependency graphs of Nix derivations";
        };
        nvd = {
          exec = "${lib.getExe pkgs.nvd} \"$@\"";
          description = "Diff two nix toplevels and show which packages were upgraded";
        };
        nix-diff = {
          exec = "${lib.getExe pkgs.nix-diff} \"$@\"";
          description = "Explain why two Nix derivations differ";
        };
        nix-output-monitor = {
          exec = "${lib.getExe pkgs.nix-output-monitor} \"$@\"";
          description = "Nix Output Monitor (a drop-in alternative for `nix` which shows a build graph)";
        };

        # These reference packages that were in the devshell example, but don't exist in your flake yet.
        # I've commented out the `exec` lines so it doesn't break your flake evaluation until you add them.
        nix-flake-update = {
          # exec = "${lib.getExe config.packages.nix-flake-update} \"$@\"";
          exec = "echo 'Please define config.packages.nix-flake-update'";
          description = "Update flake inputs with GitHub access token";
        };
        update-pkgs = {
          # exec = "${lib.getExe config.packages.update-pkgs} \"$@\"";
          exec = "echo 'Please define config.packages.update-pkgs'";
          description = "Update custom package sources via nix-update";
        };
        list-infra = {
          # exec = "${lib.getExe config.packages.list-infra} \"$@\"";
          exec = "echo 'Please define config.packages.list-infra'";
          description = "List all flake environments and hosts with details";
        };
        nix-flake-build = {
          # exec = "${lib.getExe config.packages.nix-flake-build} \"$@\"";
          exec = "echo 'Please define config.packages.nix-flake-build'";
          description = "Build a host configuration";
        };
        update-host-keys = {
          # exec = "${lib.getExe config.packages.update-host-keys} \"$@\"";
          exec = "echo 'Please define config.packages.update-host-keys'";
          description = "Collect and encrypt SSH host keys from all configured hosts";
        };
        nix-flake-provision-keys = {
          # exec = "${lib.getExe config.packages.nix-flake-provision-keys} \"$@\"";
          exec = "echo 'Please define config.packages.nix-flake-provision-keys'";
          description = "Provision SSH host keys and disk encryption secrets for a NixOS host";
        };
        nix-flake-install = {
          # exec = "${lib.getExe config.packages.nix-flake-install} \"$@\"";
          exec = "echo 'Please define config.packages.nix-flake-install'";
          description = "Install NixOS remotely using nixos-anywhere with SSH keys and disk encryption";
        };
        impermanence-copy = {
          # exec = "${lib.getExe config.packages.impermanence-copy} \"$@\"";
          exec = "echo 'Please define config.packages.impermanence-copy'";
          description = "Copy existing data to impermanence persistent storage for a host";
        };
        update-tang-disk-keys = {
          # exec = "${lib.getExe config.packages.update-tang-disk-keys} \"$@\"";
          exec = "echo 'Please define config.packages.update-tang-disk-keys'";
          description = "Update disk encryption keys using Tang servers and TPM2";
        };
      };

      # pre-commit hooks
      # If you were pulling pre-commit hooks from somewhere else:
      # enterShell = config.pre-commit.installationScript;
      # However, if you want to use devenv's native pre-commit feature you can simply do:
      # pre-commit.hooks = {
      #   treefmt.enable = true;
      #   shellcheck.enable = true;
      # };
    };
  };
}
