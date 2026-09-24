{
  inputs,
  ...
}:
{

  # flake-file.check-hooks = { config, ... }: [
  #   {
  #     exec = config.treefmt.build.wrapper;
  #     index = 10;
  #   }
  # ];

  # flake-file.formatter = pkgs: config.flake.formatter.${pkgs.stdenv.hostPlatform.system};

  # flake-file.formatter = pkgs: inputs.pedantix.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # flake-file.formatter = pkgs: inputs.pedantix.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # flake-file.write-hooks = [
  #   {
  #     exec = config.treefmt.build.wrapper;
  #     index = 10;
  #   }
  # ];

  flake-file.inputs = {
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    nixfmt-rs.url = "github:Mic92/nixfmt-rs";
    pedantix.url = "github:swarsel/pedantix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.pedantix.flakeModules.default
    inputs.git-hooks-nix.flakeModule
  ];

  perSystem =
    {
      config,
      system,
      ...
    }:
    {
      # Provide a formatter package for `nix fmt`. Setting this
      # to `config.treefmt.build.wrapper` will use the treefmt
      # package wrapped with my desired configuration.
      # Reference: https://flake.parts/options/flake-parts#opt-perSystem.formatter
      formatter = config.treefmt.build.wrapper;

      # packages.fmt = self'.formatter;

      # packages.fmt = config.treefmt.build.wrapper;
      # This automatically adds a hook which uses prek. .
      # NOTE: Wire this up in consideration of the whole repo's hook
      # more tools like devenv might want to control this. . .
      #
      # pre-commit.settings.hooks.treefmt.enable = true;
      treefmt = {
        inherit (config.flake-root) projectRootFile;
        enableDefaultExcludes = true;

        programs = {
          deadnix.enable = true;
          mdformat.enable = true;
          shellcheck.enable = true;
          statix.enable = true;
          stylua.enable = true;
          taplo.enable = true;
          toml-sort.enable = true;
          yamlfmt.enable = true;
          yamllint.enable = true;
        };

        programs.nixf-diagnose = {
          enable = true;

          ignore = [
            "sema-unused-def-let"
            "sema-primop-overridden"
          ];
        };

        programs.nixfmt = {
          enable = true;
          package = inputs.nixfmt-rs.packages.${system}.default;
        };

        programs.pedantix = {
          enable = true;

          settings = {
            args = {
              first = [
                "config"
                "lib"
                "pkgs"
                "options"
                "modulesPath"
                "utils"
              ];

              last = [
                "<defaulted>"
                "..."
              ];
            };

            attrs = {
              blank-lines = 1;

              first = [
                "flake-file"
                "imports"
                "options"
                "config"
                "enable"
                "package"
              ];

              last = [ "meta" ];

            };

            formatter = "nixfmt";

            lets = {
              sort = true;
            };

            overrides = [
              {
                attrs.sort = false;
                path = "**.treefmt.*";
              }
              {
                attrs.first = [
                  "options"
                  "includes"
                  "settings"
                  "os"
                  "nixos"
                  "homeManager"
                ];

                path = "den.**.*";
              }
              {

                attrs.first = [
                  "options"
                  "includes"
                  "settings"
                  "os"
                  "nixos"
                  "homeManager"
                ];

                path = "core.**.*";

              }
            ];

            top-level-blank-lines = 1;
            top-level-blank-lines-depth = 2;

          };

        };

        settings = {
          global.excludes = [
            # Ignore this as its handled by "flake-file.formatter"
            "flake.nix"
            "README.md"

            "LICENSE"
            "config/*"
            "docs/*"
            ".secrets/**"
            ".envrc"
            ".direnv/*"
            "*/.gitignore"
            # Underscore-prefixed files/dirs are ignored by the module auto-import system
            "**/_*/**"
            "**/_*"
          ]
          # Exclude generated files from the files.files flake-parts module
          ++ config.files.paths;

          # on-unmatched = "fatal";
          on-unmatched = "info";
        };
      };
    };
}
