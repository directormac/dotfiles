{
  inputs,
  den,
  ...
}: {
  # create an `eg` (example!) namespace. (flake exposed)
  # imports = [(inputs.den.namespace "artifex" true)];

  # you can have more than one namespace (false = not flake exposed)
  # imports = [ (inputs.den.namespace "my" false) ];

  # you can also merge many namespaces from remote flakes.
  # keep in mind a namespace is defined only once, so give it an array:
  # imports = [ (inputs.den.namespace "ours" [inputs.ours inputs.theirs]) ];

  # Enable the den dendritic module framework with angle-bracket import syntax.
  # <desktop/niri> resolves to modules/gui/desktop/niri-desktop.nix via __findFile.
  # The flake-file + import-tree integration allows the modules/ directory
  # structure to drive all imports and host definitions automatically.
  _module.args.__findFile = den.lib.__findFile;

  imports = [
    (inputs.flake-file.flakeModules.dendritic or {})
    (inputs.den.flakeModules.dendritic or {})
    (inputs.den.namespace "artifex" true)
  ];
}
