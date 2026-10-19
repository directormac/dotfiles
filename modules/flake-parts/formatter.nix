{
  generated-header,
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
        ".treefmt.toml".source = pkgs.runCommand "treefmt.toml" { } ''
          cat \
            ${
              pkgs.writeText "generated-header" (generated-header {
                source = "modules/flake-parts/formatter.nix";
                style = "hash";
              })
            } \
            ${config.treefmt.build.configFile} > $out
        '';
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

      # Known formatters
      # https://treefmt.com/formatters/
      treefmt = {
        inherit (config.flake-root) projectRootFile;
        enableDefaultExcludes = true;

        programs = {
          deadnix.enable = true;
          mdformat.enable = true;
          statix.enable = true;
          # TOML is handled by taplo alone. `toml-sort` used to be enabled as
          # well, but the two formatters disagree about the layout of arrays
          # and tables: taplo expands them, toml-sort collapses them again, so
          # every file was rewritten on each run (and the `#:schema` header
          # comments were mangled). The conform configuration in `.nvim.lua`
          # pairs TOML with taplo, so treefmt does the same.
          taplo.enable = true;
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

        programs.oxfmt = {
          enable = true;

          # The oxfmt defaults also cover markdown, YAML, CSS, JS/TS and the
          # other web formats. Those are handled by mdformat/yamlfmt here and
          # by the conform configuration in `.nvim.lua`, so oxfmt is limited to
          # the JSON dialects to keep the two in sync.
          includes = [
            "*.json"
            "*.jsonc"
          ];
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
              # Module option sets: `enable` is always the first binding and
              # `settings` the second one, so that both are easy to spot and
              # hard to forget. The `**` on both sides matches at any depth
              # (`programs.foo`, `programs.foo.bar`, `systemd.services.foo`,
              # `den.aspects.<x>.homeManager.programs.foo`, ...).
              {
                attrs.first = [
                  "enable"
                  "settings"
                ];

                path = "**.programs.**";
              }
              {
                attrs.first = [
                  "enable"
                  "settings"
                ];

                path = "**.services.**";
              }
            ];

            top-level-blank-lines = 1;
            top-level-blank-lines-depth = 2;

          };

        };

        programs.shellcheck = {
          enable = true;

          # The remaining shell scripts are zsh flavoured: they use syntax
          # that neither shellcheck nor shfmt can parse.
          excludes = [
            "config/scripts/fzf-git.sh"
            "config/scripts/fzf-mise.sh"
            "config/scripts/session-wizard.sh"
            "config/zsh/**"
          ];

          # The treefmt-nix default is `*.envrc.*`, which also matches editor
          # scratch files such as `.conform.<pid>.envrc.nix` (conform writes its
          # temporary copies next to the buffer). Shellcheck then parsed the
          # whole Nix file as shell and failed the format run. `.envrc.*`
          # (leading dot) only matches real direnv variants.
          #
          # `*.zsh` is deliberately *not* included: shellcheck cannot parse zsh
          # at all (SC1071) and aborts the whole format run because of it.
          includes = [
            "*.sh"
            "*.bash"
            "*.envrc"
            ".envrc.*"
          ];

          # Only real errors abort the format run. Style/warning/info findings
          # are advisory (e.g. SC2034 on the `format_*` variables of
          # `config/tmux/scripts/custom-number.sh`, which are read indirectly
          # through `eval`) and would otherwise break `nix fmt` and every
          # conform save in the editor.
          severity = "error";
        };

        programs.shfmt = {
          enable = true;

          # shfmt only understands POSIX/bash, so the zsh flavoured scripts
          # are left alone (same list as for shellcheck).
          excludes = [
            "config/scripts/fzf-git.sh"
            "config/scripts/fzf-mise.sh"
            "config/scripts/session-wizard.sh"
            "config/zsh/**"
          ];

          indent_size = 2;
          simplify = true;
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

        programs.yamlfmt = {
          enable = true;

          settings = {
            formatter = {
              escape_unicode = false;
              type = "basic";
            };
          };

          # yamlfmt escapes plane-15/16 PUA glyphs (U+E0000+, where the Nerd
          # Font icons live) to \UXXXXXXXX even with escape_unicode = false.
          # tmux-nerd-font-window-name parses this file with a plain awk
          # script that cannot decode those escapes, which would break the
          # icons, so skip yamlfmt for it (yamllint still checks it).
          # The glob also covers conform's temp copies
          # (config/tmux/.conform.<pid>.<name>.yml) used when saving in nvim.
          excludes = [ "config/tmux/*tmux-nerd-font-window-name*" ];

        };

        programs.yamllint = {
          enable = true;

          settings.rules = {
            # Single space before trailing comments (e.g. lsd/colors.yaml)
            comments.min-spaces-from-content = 1;
            # Repo convention: YAML config files don't start with "---"
            document-start.present = false;

            # Comments (aliases, URLs, aligned columns) legitimately exceed 80;
            # match stylua's column_width instead
            line-length = {
              allow-non-breakable-inline-mappings = true;
              allow-non-breakable-words = true;
              max = 120;
            };
          };
        };

        settings = {
          global.excludes = lib.unique (
            [
              "LICENSE"
              "config/archived/**"
              "nixos/*"
              "docs/*"
              ".secrets/**"
              ".envrc"
              ".direnv/*"
              "*/.gitignore"
              # Note: do NOT exclude `**/.conform.*` or `**/_*` here.
              # `conform.nvim` invokes `treefmt` with `stdin = false` on a temporary
              # `.conform.<id>.<name>` copy next to the buffer; excluding `**/.conform.*`
              # makes `treefmt` skip every file saved in Neovim. And `_`-prefixed Nix
              # helper modules (`tmux/_*.nix`, `zsh/_*.nix`, `browsers/_common/*.nix`)
              # are valid Nix code that should be formatted like the rest of `modules/`.
              "**/.otter.*"
              # DMS (DankMaterialShell) regenerates these files at runtime
              # ("Auto-generated by DMS - do not edit manually"). Formatting them
              # only leads to a fight with the running desktop shell, which
              # rewrites them with its own layout.
              "config/*/dms/**"
            ]
            # Exclude generated files from the files.files flake-parts module
            ++ (if config ? files && config.files ? paths then config.files.paths else [ ])
          );

          # on-unmatched = "fatal";
          on-unmatched = "info";
        };
      };
    };
}
