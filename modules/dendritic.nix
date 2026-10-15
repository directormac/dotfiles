{ inputs, ... }:
{
  imports = [

    /**
      # The glue to `flake-parts`
    */
    inputs.den.flakeModule

    (inputs.flake-file.flakeModules.dendritic or { })
    (inputs.den.flakeModules.dendritic or { })
  ];

}
