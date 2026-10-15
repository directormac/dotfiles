# Development shell providing tools for working with this configuration:
# Enter with `nix develop` or via direnv.
{ inputs, ... }: {
  flake-file = {
    inputs = {
      devenv.url = "github:cachix/devenv";

      # devenv needs the project directory. Without this it falls back to `builtins.getEnv "PWD"`, which is empty under pure
      #  evaluation.
      # /dev/null` keeps the declaration host-independent (since `.devenv/root` is gitignored); `.envrc` overrides it
      #  per-checkout.
      devenv-root = {
        flake = false;
        url = "file+file:///dev/null";
      };

      make-shell.url = "github:nicknovitski/make-shell";
      mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
      nix2container.url = "github:nlewo/nix2container";
    };

    nixConfig = {
      extra-substituters = [
        "https://devenv.cachix.org"
      ];

      extra-trusted-public-keys = [
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
    };
  };

  imports = [
    (inputs.devenv.flakeModule or { })
    (inputs.make-shell.flakeModules.default or { })
  ];

  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    lib.optionalAttrs (inputs ? devenv) {
      # Per-system attributes can be defined here. The self' and inputs'
      # module parameters provide easy access to attributes of the same
      # system.
      # https://devenv.sh/reference/options/
      devenv.shells.default = {
        devenv.root =
          let
            devenvRootFile = builtins.readFile inputs.devenv-root.outPath;
          in
          if devenvRootFile != "" then devenvRootFile else toString ../..;

        # https://devenv.sh/basics/
        enterShell = ''
          alias sandbox="nix run .#vm-sandbox"
          alias vm-sandbox="nix run .#vm-sandbox"
          alias vm="nix run .#vm"
          alias vm-nixos="nix run .#vm-nixos"
          alias vm-super="nix run .#vm-super"
        '';

        # https://devenv.sh/tests/
        # enterTest = ''
        #   echo "Running tests"
        #   git --version | grep --color=auto "${pkgs.git.version}"
        # '';
        # https://devenv.sh/git-hooks/
        # git-hooks.hooks.shellcheck.enable = true;
        # git-hooks.hooks = {
        #   # treefmt.enable = true;
        # };

        # languages = {
        #   lua.enable = true;
        #   nix.enable = true;
        # };

        # https://devenv.sh/packages/
        packages = [
          # Secrets
          pkgs.age
          pkgs.secretspec
          pkgs.sops

          # Cli
          pkgs.just
          pkgs.git
          pkgs.gh

          # nixnixnix
          pkgs.nix # Always use the nix version from this flake's nixpkgs version
          pkgs.nixos-rebuild # Ensure nixos-rebuild is available for darwin systems
          pkgs.nix-output-monitor
          pkgs.nix-fast-build
          # pkgs.nh

          pkgs.nix-search-tv
          pkgs.fzf
        ]
        ++ lib.optionals (config ? treefmt) [
          config.treefmt.build.programs.pedantix
          config.treefmt.build.programs.nixfmt
          # config.treefmt.build.programs.statix
          config.treefmt.build.wrapper
        ]
        ++ lib.optionals pkgs.stdenv.buildPlatform.isDarwin [
          pkgs.coreutils-full # Include GNU coreutils for darwin systems
        ];

        # https://devenv.sh/scripts/
        scripts = {
          fmt = {
            description = "Format all files with treefmt";
            exec = "treefmt \"$@\"";
          };

          nix-tree = {
            description = "Interactively browse dependency graphs of Nix derivations";
            exec = "${lib.getExe pkgs.nix-tree} \"$@\"";
          };

          /**
            # --- GUIDE: How to create custom scripts in devenv ---

            Option 1 (Simple Inline Script):
            If your script is just a few lines of bash, you can write it directly in `exec`.
            Any package you add to `devenv.shells.default.packages` will be available in the PATH.
            example-script = {
              exec = ''
                echo "Hello World"
                rg "something" # Assuming pkgs.ripgrep is in your packages list
              '';
              description = "An example inline script";
            };

            Option 2 (Wrapped Executable):
            If you are wrapping an existing derivation or `writeShellApplication` to ensure
            it has isolated dependencies (like `fzf`), you can evaluate it and call its binary.
            We use `lib.getExe` to get the path to the main binary of the derivation.
          */
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
            description = "Search nixpkgs interactively using nix-search-tv and fzf";

            exec =
              let
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
              in
              "${lib.getExe nsApp} \"$@\"";
          };

          os-switch = {
            description = "Switch NixOS configuration using nh";
            exec = "nix run .#os -- switch \"$@\"";
          };

          os-test = {
            description = "Test NixOS configuration using nh";
            exec = "nix run .#os -- test \"$@\"";
          };

          rekey = {
            description = "Rekey all secrets with agenix-rekey";
            exec = "agenix rekey -a \"$@\"";
          };

          # Using built-in packages:
          # nh = {
          #   description = "Nix helper for nixpkgs development";
          #   exec = "${lib.getExe pkgs.nh} \"$@\"";
          # };
          sandbox = {
            description = "Run sandbox in a QEMU VM";
            exec = "nix run .#vm-sandbox \"$@\"";
          };

          vm = {
            description = "Run default VM";
            exec = "nix run .#vm \"$@\"";
          };

          vm-nixos = {
            description = "Run nixos host in a QEMU VM";
            exec = "nix run .#vm-nixos \"$@\"";
          };

          vm-sandbox = {
            description = "Run sandbox in a QEMU VM";
            exec = "nix run .#vm-sandbox \"$@\"";
          };

          vm-super = {
            description = "Run super host in a QEMU VM";
            exec = "nix run .#vm-super \"$@\"";
          };

          write-files = {
            description = "Regenerate files (e.g. README.md)";
            exec = "nix run .#write-files \"$@\"";
          };

          write-flake = {
            description = "Regenerate root flake.nix using flake-file";
            exec = "nix run .#write-flake \"$@\"";
          };
          # treefmt = {
          #   description = "Format all files";
          #   exec = "${config.treefmt.build.wrapper}/bin/treefmt \"$@\"";
          # };

        };
      };
    };
}
