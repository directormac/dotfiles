{
  inputs,
  withSystem,
  ...
}:
{
  flake-file.formatter =
    pkgs:
    let
      treefmt = withSystem pkgs.stdenv.hostPlatform.system (
        { config, ... }: config.treefmt.build.wrapper
      );
    in
    pkgs.writeShellScriptBin "treefmt-flake" ''
      export HOME=$(mktemp -d)
      exec ${treefmt}/bin/treefmt --no-cache "$@"
    '';

  flake-file.inputs = {
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    nixfmt-rs.url = "github:Mic92/nixfmt-rs";
    pedantix.url = "github:swarsel/pedantix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  imports = [
    (inputs.treefmt-nix.flakeModule or { })
    (inputs.pedantix.flakeModules.default or { })
    (inputs.git-hooks-nix.flakeModule or { })
  ];

  perSystem =
    {
      config,
      lib,
      pkgs,
      system,
      ...
    }:

    lib.optionalAttrs (inputs ? treefmt-nix) {

      # Create a treefmt file
      files.file = lib.mkIf (inputs ? files) {
        ".treefmt.toml".source = config.treefmt.build.configFile;
      };

      # Provide a formatter package for `nix fmt`. Setting this
      # to `config.treefmt.build.wrapper` will use the treefmt
      # package wrapped with my desired configuration.
      # Reference: https://flake.parts/options/flake-parts#opt-perSystem.formatter
      formatter = config.treefmt.build.wrapper;
      packages.fmt = config.treefmt.build.wrapper;
      packages.treefmt = config.treefmt.build.wrapper;

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
          package = inputs.nixfmt-rs.packages.${system}.default or pkgs.nixfmt;
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

        programs.stylua = {
          enable = true;

          settings = {
            collapse_simple_statement = "Always";
            column_width = 120;
            indent_type = "Spaces";
            indent_width = 2;
            line_endings = "Unix";
            quote_style = "AutoPreferSingle";
            # call_parentheses = "None"
            sort_requires.enabled = true;
          };

        };

        settings = {
          global.excludes = [
            "LICENSE"
            "config/archived/**"
            "nixos/*"
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
          ++ (if config ? files && config.files ? paths then config.files.paths else [ ]);

          # on-unmatched = "fatal";
          on-unmatched = "info";
        };
      };
    };
}
