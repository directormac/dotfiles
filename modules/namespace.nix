# Creates and exports the "core" namespace for aspects.
{ den, inputs, ... }:
{
  # Create and export the "core" namespace (flake exposed)
  imports = [ (inputs.den.namespace "core" true) ];
  # Enable Den angle-bracket syntax in modules (<core/vm>, etc.)
  _module.args.__findFile = den.lib.__findFile;
  # Ensure the namespace is defined
  core = { };
}
