let
  flake = builtins.getFlake "git+file:///home/artifex/Public/den";
  modules = flake.inputs.import-tree ./modules;
in
  builtins.hasAttr "environments" modules
