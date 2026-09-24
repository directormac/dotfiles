{ inputs, ... }: {
  imports = [
    /**
      # The glue to `flake-parts`
    */
    inputs.den.flakeModule

    /**
      # Flake Outputs

      This allows us to utilize flake outputs like `packages`, `checks`, etc.

      [packages-merge.nix](https://github.com/denful/den/blob/main/templates/ci/modules/public-api/packages-merge.nix)
    */
    # inputs.den.flakeOutputs.packages
  ];

  /**
    # Outputs
    This should be at `modules/schema/flake.nix`
    but that would be confusing in having multiple `flake.nix`
  */
  # den.schema.flake-system.includes = [ den.aspects.flake ];

}
