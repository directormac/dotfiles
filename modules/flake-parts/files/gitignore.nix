{
  config,
  lib,
  dag,
  ...
}:
{
  options.flake.dot-gitignore = lib.mkOption {
    default = { };
    description = "DAG of sections to assemble into .gitignore";
    type = lib.types.lazyAttrsOf lib.types.unspecified;
  };

  config = {

    flake.dot-gitignore.root =
      dag.entryAnywhere
        # gitignore
        ''
          # Do not edit edit gitignore.nix
          result
          *.qcow2
          tmp
          .pi/goals
          .pi/.goals-pool-snapshot.json
          .opencode/goals

          # Devenv
          .devenv*
          devenv.local.nix
          devenv.local.yaml

          # direnv
          .direnv

          # pre-commit
          .pre-commit-config.yaml
          .treefmt.toml

          .secrets/master.age
        '';

    perSystem = {
      files.file.".gitignore".text = dag.render {
        entries = config.flake.dot-gitignore;
        separator = "\n";
      };
    };
  };
}
