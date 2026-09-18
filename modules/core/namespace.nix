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
    (inputs.den.namespace "runner" true)
  ];

  # you can have more than one namespace (false = not flake exposed)
  # imports = [ (inputs.den.namespace "my" false) ];

  # you can also merge many namespaces from remote flakes.
  # keep in mind a namespace is defined only once, so give it an array:
  # imports = [ (inputs.den.namespace "ours" [inputs.ours inputs.theirs]) ];

  # this line enables den angle brackets syntax in modules.
  _module.args.__findFile = den.lib.__findFile;
}
