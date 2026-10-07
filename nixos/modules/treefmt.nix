{
  perSystem =
    {
      config,
      pkgs,
      # self',
      ...
    }:
    {
      formatter = config.treefmt.build.wrapper;

      # packages.fmt = self'.formatter;

      treefmt = {
        inherit (config.flake-root) projectRootFile;
        # projectRootFile = ".git";

        enableDefaultExcludes = true;

        settings = {
          on-unmatched = "warn";
        };

        programs = {
          autocorrect.enable = true;
          nixfmt = {
            enable = true;
            package = pkgs.nixfmt;
            includes = [ "**/*.nix" ];
          };
          nixf-diagnose = {
            enable = true;
            ignore = [
              "sema-unused-def-lambda-witharg-formal"
              "sema-unused-def-lambda-noarg-formal"
              "sema-primop-overridden"
              "sema-unused-def-let"
            ];
          };
          taplo.enable = true;
          yamlfmt = {
            enable = true;
          };
          kdlfmt.enable = true;
          toml-sort.enable = true;
          shfmt.enable = true;
          shellcheck.enable = true;
          # picks up the per-directory .stylua.toml files
          stylua.enable = true;
        };
      };
    };
}
