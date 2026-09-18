{inputs, ...}: {
  flake-file.inputs = {
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      # inputs.nixpkgs.follows = "nixpkgs";
      #
    };

    # treefmt-nix.url = "github:numtide/treefmt-nix";
    # treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = {
    inputs',
    config,
    pkgs,
    ...
  }: {
    # devshells.default.packages = [ inputs'.statix.packages.default ];

    # Provide a formatter package for `nix fmt`. Setting this
    # to `config.treefmt.build.wrapper` will use the treefmt
    # package wrapped with my desired configuration.
    formatter = config.treefmt.build.wrapper;

    treefmt = {
      inherit (config.flake-root) projectRootFile;

      enableDefaultExcludes = true;

      settings = {
        # on-unmatched = "fatal";
        on-unmatched = "info";

        global.excludes =
          [
            "config/**"
            "flake.nix"
            "generated/**"
            ".secrets/**"
            "*.editorconfig"
            "*.envrc"
            "*.gitconfig"
            "*.gitignore"
            "*CODEOWNERS"
            "*LICENSE"
            "*flake.lock"
            "*.svg"
            "*.png"
            "*.gif"
            "*.ico"
            "*.jpg"
            "*.webp"
            "*.conf"
            "*.age"
            "*.pub"
            "*.asc"
            "*.org"
            "*.zsh"
            "*.kdl"
            "*.txt"
            "*.tmpl"
            "*.jwe"
            "*.xml"
            "*.dds"
            "*.diff"
            "*.patch"
            "*.bin"
            # Underscore-prefixed files/dirs are ignored by the module auto-import system
            "**/_*/**"
            "**/_*"
          ]
          # Exclude generated files from the files.files flake-parts module
          ++ config.files.paths;

        # statix.options = [ "explain" ];
        mdformat.options = ["--number"];
        shellcheck.options = [
          "--shell=bash"
          "--check-sourced"
        ];
        yamlfmt.options = [
          "-formatter"
          "retain_line_breaks=true"
        ];
        formatter = {
        };
      };

      programs = {
        isort.enable = true;
        alejandra.enable = true;
        statix.enable = true;

        # nixfmt = {
        #   enable = true;
        #   package = pkgs.nixfmt;
        #   includes = ["**/*.nix"];
        # };

        taplo.enable = true;

        yamlfmt = {
          enable = true;
        };

        toml-sort.enable = true;

        mdformat.enable = true;

        shellcheck.enable = true;
      };
    };
  };
}
