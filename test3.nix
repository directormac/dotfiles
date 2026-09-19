let
  flake = builtins.getFlake "git+file:///home/artifex/Public/den";
in
  builtins.attrNames flake.legacyPackages.x86_64-linux
# wait, flake-parts exposes config through legacyPackages? No.

