let
  flake = builtins.getFlake "git+file:///home/artifex/Public/den";
in
  flake.nixosConfigurations
