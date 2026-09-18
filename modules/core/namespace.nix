/**
* Namespaces & Imports
*
* This module sets up custom Den namespaces which group related aspects together.
* It also enables the angle-brackets import syntax for your config files.
*
* Use Cases:
* 1. The `runner` namespace allows us to reference `runner.vm.gui` elsewhere.
* 2. The `__findFile` injection enables `<aspect/path>` shorthand for module imports.
*/
{
  inputs,
  den,
  ...
}: {
  # create a namespace (flake exposed)
  imports = [
    # You can have several namespaces,
    # - true: exposes flake.denful.yours
    # - false: Not flake exposed.

    # You can also mixin from several inputs.
    # Just keep in mind that a namespace can be defined only once, use an array as argument:
    # (inputs.den.namespace "ours" [
    #   true
    #   inputs.mine
    #   inputs.theirs
    # ])

    (inputs.den.namespace "runner" true)
  ];

  # you can have more than one namespace (false = not flake exposed)
  # imports = [ (inputs.den.namespace "my" false) ];

  # you can also merge many namespaces from remote flakes.
  # keep in mind a namespace is defined only once, so give it an array:
  # imports = [ (inputs.den.namespace "ours" [inputs.ours inputs.theirs]) ];

  # Enable the den dendritic module framework with angle-bracket import syntax.
  # <desktop/niri> resolves to modules/aspects/editors/helix.nix via __findFile.
  # The flake-file + import-tree integration allows the modules/ directory
  # structure to drive all imports and host definitions automatically.
  _module.args.__findFile = den.lib.__findFile;
}
